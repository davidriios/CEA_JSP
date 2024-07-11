<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"100027") || SecMgr.checkAccess(session.getId(),"100028") || SecMgr.checkAccess(session.getId(),"100029") || SecMgr.checkAccess(session.getId(),"100030"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta p�gina.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String status = request.getParameter("status");

if (status == null || status.trim().equals("")) status = "";
else appendFilter = " where status='"+status+"'";

if (request.getMethod().equalsIgnoreCase("GET"))
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
	String name="",description="";
	if (request.getParameter("name") != null && !request.getParameter("name").trim().equals(""))
	{
		if (appendFilter.trim().equals("")) appendFilter += " where";
		else appendFilter += " and";
		appendFilter += " upper(name) like '%"+request.getParameter("name").toUpperCase()+"%'";
	    name = request.getParameter("name");
 	}
	if (request.getParameter("description") != null && !request.getParameter("description").trim().equals(""))
	{
		if (appendFilter.trim().equals("")) appendFilter += " where";
		else appendFilter += " and";
		appendFilter += " upper(description) like '%"+request.getParameter("description").toUpperCase()+"%'";
	    description = request.getParameter("description");
	}	
  

	sql = "select id, name, description, status from tbl_sec_regvar"+appendFilter+" order by name";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from tbl_sec_regvar"+appendFilter);

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
document.title = 'Administraci�n - Variables Ambiente - '+document.title;
function add(){abrir_ventana('../admin/reg_regvar.jsp');}
function edit(id){abrir_ventana('../admin/reg_regvar.jsp?mode=edit&id='+id);}
function printList(){abrir_ventana('../admin/print_list_regvar.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMINISTRACION - VARIABLES AMBIENTE"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;<!--<authtype type='50'><a href="javascript:add()" class="Link00">[ Registrar Nueva Variable Ambiente ]</a></authtype>--></td>
</tr>
<tr>
	<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<table width="100%" cellpadding="1" cellspacing="1">
		
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<tr class="TextFilter">
			<td width="30%">Estado<%=fb.select("status","A=ACTIVO,I=INACTIVO",status,"T")%></td>
			<td width="30%">
				<cellbytelabel>Nombre</cellbytelabel>
				<%=fb.textBox("name","",false,false,false,30)%>
			</td>
			<td width="40%">
				<cellbytelabel>Descripci&oacute;n</cellbytelabel>
				<%=fb.textBox("description","",false,false,false,50)%>
				<%=fb.submit("go","Ir")%>
			</td>
		</tr>

<%=fb.formEnd()%>
		</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

	</td>
</tr>
<tr>
	<td align="right">&nbsp;<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype></td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("name",name)%>
<%=fb.hidden("description",description)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("name",name)%>
<%=fb.hidden("description",description)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>	

<table width="99%" cellpadding="0" cellspacing="0" align="center">
<tr>
	<td class="TableLeftBorder TableRightBorder">
		
	<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="30%"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="50%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Estado</cellbytelabel></td>
			<td width="10%">&nbsp;</td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("name")%></td>
			<td><%=cdo.getColValue("description")%></td>
			<td align="center"><%=(cdo.getColValue("status").equalsIgnoreCase("A"))?"Activo":"Inactivo"%></td>
			<td align="center"><authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("id")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Editar</cellbytelabel></a></authtype></td>
		</tr>
<%
}
%>				
		</table>
	</td>
</tr>		
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("name",name)%>
<%=fb.hidden("description",description)%>

			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("name",name)%>
<%=fb.hidden("description",description)%>

			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
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