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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
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
  String codigo="",descripcion="",tipo="";
  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))  
  {
    if(appendFilter.trim().equals(""))appendFilter +=" WHERE ";
	else appendFilter +=" and ";
    appendFilter += "  upper(codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    codigo = request.getParameter("codigo");
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))  
  {
    if(appendFilter.trim().equals(""))appendFilter +=" WHERE ";
	else appendFilter +=" and ";
	appendFilter += "  upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    descripcion = request.getParameter("descripcion");
  }
  if (request.getParameter("tipo") != null && !request.getParameter("tipo").trim().equals(""))  
  {
    if(appendFilter.trim().equals(""))appendFilter +=" WHERE ";
	else appendFilter +=" and ";
	appendFilter += "  tipo = '"+request.getParameter("tipo")+"'";
    tipo = request.getParameter("tipo");
  }
  else 
  {
  if(appendFilter.trim().equals(""))appendFilter +=" WHERE ";
	else appendFilter +=" and ";
	
	appendFilter += " tipo in ('A','N') ";
  }

  sql = " SELECT codigo, descripcion, decode(tipo,'A','ADULTOS','N','NIÑOS') tipo,decode(estado,'A','ACTIVO','I','INACTIVO','') estado FROM tbl_sal_tipo_escala "+appendFilter+" ORDER BY codigo ASC ";
  al = SQLMgr.getDataList(" select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount(" SELECT count(*) FROM tbl_sal_tipo_escala "+appendFilter);

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
document.title = 'Tipo de escala Glasgow - '+document.title;
function add()
{
	abrir_ventana('tipo_escala_glasgow_config.jsp');
}
function edit(id)
{
	abrir_ventana('tipo_escala_glasgow_config.jsp?mode=edit&id='+id);
}
function printList()
{
	abrir_ventana('print_list_tipo_escala_glasgow.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - MANTENIMIENTO - GENERALES DE TIPO DE ESCALA GLASGOW"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
<td align="right">&nbsp;
       <authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel id="1">Registrar Nuevo Tipo Escala</cellbytelabel> ]</a></authtype>
</td>
</tr>
<tr>
<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->		
<table width="100%" cellpadding="0" cellspacing="1">
<% fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp"); %>
<%=fb.formStart()%>
<tr class="TextFilter">
	<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
	<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
	<td width="35%"><cellbytelabel id="2">C&oacute;digo</cellbytelabel> <%=fb.textBox("codigo",request.getParameter("codigo"),false,false,false,30,null,null,null)%></td>
	<td width="35%"><cellbytelabel id="3">Descripci&oacute;n</cellbytelabel> <%=fb.textBox("descripcion",request.getParameter("descripcion"),false,false,false,40,null,null,null)%></td>	
	<td width="30%"><cellbytelabel id="4">Tipo</cellbytelabel><%=fb.select("tipo","A=ADULTOS,N=NIÑOS",tipo,false,false,0,"T")%>   <%=fb.submit("go","Ir")%></td>	
</tr>
<%=fb.formEnd()%>
</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
    <tr>
        <td align="right">&nbsp;
					<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel id="5">Imprimir Lista</cellbytelabel> ]</a></authtype>
				</td>
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
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("descripcion",""+descripcion)%>
					<%=fb.hidden("tipo",""+tipo)%>
 
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="6">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="7">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="8">hasta</cellbytelabel> <%=nVal%></td>
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
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("descripcion",""+descripcion)%>
					<%=fb.hidden("tipo",""+tipo)%>
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
<td width="15%"><cellbytelabel id="2">C&oacute;digo</cellbytelabel></td>
<td width="45%"><cellbytelabel id="3">Descripci&oacute;n</cellbytelabel></td>
<td width="15%" align="center"><cellbytelabel id="4">Tipo</cellbytelabel></td>
<td width="15%" align="center"><cellbytelabel id="9">Estado</cellbytelabel></td>
<td width="10%">&nbsp;</td>
</tr>	
<%
for (int i=0; i<al.size(); i++){
CommonDataObject cdo = (CommonDataObject) al.get(i);
String color = "TextRow02";
if (i % 2 == 0) color = "TextRow01";
%>
<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
<td><%=cdo.getColValue("codigo")%></td>
<td><%=cdo.getColValue("descripcion")%></td>					
<td align="center"><%=cdo.getColValue("tipo")%></td>
<td align="center"><%=cdo.getColValue("estado")%></td>					
<td align="center">&nbsp;
	<authtype type='4'><a href="javascript:edit('<%=cdo.getColValue("codigo")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel id="10">Editar</cellbytelabel></a></authtype>
</td>
</tr>
<% } %>	
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
				fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
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
				<%=fb.hidden("codigo",""+codigo)%>
				<%=fb.hidden("descripcion",""+descripcion)%>
				<%=fb.hidden("tipo",""+tipo)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="6">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="7">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="8">hasta</cellbytelabel> <%=nVal%></td>
					<%
					fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
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
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("descripcion",""+descripcion)%>
					<%=fb.hidden("tipo",""+tipo)%>
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