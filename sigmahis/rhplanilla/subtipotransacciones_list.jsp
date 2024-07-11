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
/**
==================================================================================

==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"") || SecMgr.checkAccess(session.getId(),"") || SecMgr.checkAccess(session.getId(),"") || SecMgr.checkAccess(session.getId(),""))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");

UserDet = SecMgr.getUserDetails(session.getId());
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 2;
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



String transaccion="";
if (request.getParameter("transaccion")!=null){
transaccion=request.getParameter("transaccion").toUpperCase(); 
appendFilter+=" and transaccion like '"+transaccion+"%' ";
}




/*
  if (request.getParameter("codigo") != null)
  { appendFilter += " Where upper() like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    searchOn = ""; searchVal = request.getParameter("codigo");
    searchType = "1"; searchDisp = "Código";
  }
*/
  
/*
  else if (request.getParameter("descripcion") != null)
  { 
    appendFilter += " Where upper() like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    searchOn = "";
    searchVal = request.getParameter("descripcion");
    searchType = "1";
    searchDisp = "Descripcion";
  }
*/  
  
  
  if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
  {
   if (searchType.equals("1"))
   {
     appendFilter += " Where upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
   }

  }
  else
  {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }


  sql = " SELECT compania, transaccion FROM tbl_pla_sub_tipo_transaccion WHERE transaccion>0 "+appendFilter+" ORDER BY codigo ASC ";
  al = SQLMgr.getDataList(" SELECT * FROM (SELECT rownum AS rn, a.* FROM ("+sql+") a) WHERE rn BETWEEN "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount(" SELECT count(*) FROM tbl_pla_tipo_transaccion WHERE codigo>0 "+appendFilter);


/*
  sql = "";
  al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
//  rowCount = CmnMgr.getCount("SELECT count(*) FROM  "+appendFilter);
*/

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
document.title = 'Tipo de Transacciones - '+document.title;

function add()
{
	abrir_ventana('tipotransacciones_config.jsp');
}

function edit(id)
{
	abrir_ventana('tipotransacciones_config.jsp?mode=edit&id='+id);
}

function printList()
{
	abrir_ventana('print_list_tipo_transaccion.jsp');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">


<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RECURSOS HUMANOS - MANTENIMIENTO - TIPO DE TRANSACCIONES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
<td align="right">
			<%
			// if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),""))
			//  {
			%>
			<a href="javascript:add()" class="LinksTextred">[ Registrar Nuevo Tipo de Transacciones ]</a>
			<%
			//}
			%>
</td>
</tr>
<tr>
<td>1</td>
</tr>
<tr>
<td align="right">
			<%
			//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),""))
			//  {
			%>
			<a href="javascript:printList()" class="LinksTextred">[ Imprimir Lista ]</a>
			<%
			//      }
			%>
</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorderRed TableTopBorderRed TableRightBorderRed">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextRegisters_Red">
				<%
				fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
					<td width="10%">
					<%
					if (preVal != 1)
					{
					%>
					<%=fb.submit("previous","<<-")%>
					<%
					}
					%>
					</td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<td width="10%" align="right">
					<%
					if (!(rowCount <= nxtVal))
					{
					%>
					<%=fb.submit("next","->>")%>
					<%
					}
					%>
					</td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>	

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorderRed TableRightBorderRed">
	
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
	
<table align="center" width="100%" cellpadding="0" cellspacing="1">
<tr class="TextColumn_Red">
<td width="5%">&nbsp;</td>
<td width="15%">C&oacute;digo</td>
<td width="70%">Descripci&oacute;n</td>
<td width="10%">&nbsp;</td>
</tr>				
<%
for (int i=0; i<al.size(); i++){
CommonDataObject cdo = (CommonDataObject) al.get(i);
String color = "TextRow_Red02";
if (i % 2 == 0) color = "TextRow_Red01";
%>
<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRow_Red01_Over')" onMouseOut="setoutc(this,'<%=color%>')">


<td align="right"><%=preVal + i%>&nbsp;</td>
<td><%=cdo.getColValue("codigo")%></td>
<td><%=cdo.getColValue("descripcion")%></td>					
<td align="center">&nbsp;
<%
//	if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),""))
//{
%>					
<a href="javascript:edit(<%=cdo.getColValue("")%>)" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Subtipos</a>
<%
//}
%>					
</td>



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
		<td class="TableLeftBorderRed TableBottomBorderRed TableRightBorderRed">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextRegisters_Red">
				<%
				fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
					<td width="10%">
					<%
					if (preVal != 1)
					{
					%>
					<%=fb.submit("previous","<<-")%>
					<%
					}
					%>
					</td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
					<td width="10%" align="right">
					<%
					if (!(rowCount <= nxtVal))
					{
					%>
					<%=fb.submit("next","->>")%>
					<%
					}
					%>
					</td>
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