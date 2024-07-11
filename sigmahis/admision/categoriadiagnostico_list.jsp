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
/*
==========================================================
500041	VER LISTA DE CATEGORÍA DIAGNÓSTIC0
500042	IMPRIMIR LISTA DE CATEGORÍA DIAGNÓSTICO
500043	AGREGAR  CATEGORÍA DIAGNÓSTICO
500044	MODIFICAR CATEGORÍA DIAGNÓSTICO
==========================================================
*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500041") || SecMgr.checkAccess(session.getId(),"500042") || SecMgr.checkAccess(session.getId(),"500043") || SecMgr.checkAccess(session.getId(),"500044"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fp = "";
String code = "";
String name = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  if (request.getParameter("fp") != null) fp = request.getParameter("fp") ;
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
		appendFilter += " where upper(codigo) like '%"+request.getParameter("code").toUpperCase()+"%'";

    searchOn = "codigo";
    searchVal = request.getParameter("code");
    searchType = "1";
    searchDisp = "Código";
    code = request.getParameter("code");	
	}
	else if (request.getParameter("name") != null)
	{
		appendFilter += " where upper(descripcion) like '%"+request.getParameter("name").toUpperCase()+"%'";

    searchOn = "descripcion";
    searchVal = request.getParameter("name");
    searchType = "1";
    searchDisp = "Nombre";
    name = request.getParameter("name");	
	}
	else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
  {
    if (searchType.equals("1"))
    {
			appendFilter += " where upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
    }
  }
  else
  {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }
	/*if (fp.equalsIgnoreCase("diag") || fp.equalsIgnoreCase("diag"))
	{*/
		sql = "select  codigo as code, descripcion as name,rango as rango from tbl_cds_categoria_diag"+appendFilter+" order by descripcion";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from tbl_cds_categoria_diag"+appendFilter);
	//}
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
<head><%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Categoría de Diagnóstico - '+document.title;

function add()
{
	abrir_ventana('../admision/categoriadiagnostico_config.jsp');
}

function edit(id)
{
	abrir_ventana('../admision/categoriadiagnostico_config.jsp?mode=edit&id='+id);
}

function printList()
{
	abrir_ventana('../admision/print_list_categoria_diagnotisco.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
function setCategoria(k)
{
	<%
	if (fp.equalsIgnoreCase("diag"))//referencia diagnostico--paciente
	{
%>
	window.opener.document.form1.categoria.value = eval('document.form0.code'+k).value;
	window.opener.document.form1.namecat.value = eval('document.form0.desc'+k).value;
	
  <%} else if(fp.equalsIgnoreCase("rCatDiag")){ %>  
	 	window.opener.document.form0.categoriaDiag.value = eval('document.form0.code'+k).value;
 	 	window.opener.document.form0.descCategDiag.value = eval('document.form0.desc'+k).value;
  <%}%>
  
	window.close();  
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="Clínico - Admisión - Mantenimiento - Categoria Diagnostico"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
    <td align="right">
	<% if (!fp.equalsIgnoreCase("diag") && !fp.equalsIgnoreCase("rCatDiag")) {%>
			<authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel id="1">Registrar Nueva Categor&iacute;a Diagn&oacute;stica</cellbytelabel> ]</a></authtype>
			<%}%>
		</td>
  </tr>
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
<table width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextFilter">
		
<%
fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fp",fp)%>
				<td width="50%">
					<cellbytelabel id="2">C&oacute;digo</cellbytelabel>
					<%=fb.textBox("code",code,false,false,false,30)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
		
<%
fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fp",fp)%>
				<td width="50%">
					<cellbytelabel id="3">Nombre</cellbytelabel>
					<%=fb.textBox("name",name,false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
		
			</tr>
</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
  <tr>
    <td align="right">
		<% if(!fp.equalsIgnoreCase("diag")	&& !fp.equalsIgnoreCase("rCatDiag")) {%>
			<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel id="4">Imprimir Lista</cellbytelabel> ]</a></authtype>
		<%}%>	
		</td>
  </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
<%
fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
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
				<%=fb.hidden("fp",fp)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel id="5">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel id="6">Registros desde</cellbytelabel> <%=pVal%><cellbytelabel id="7">hasta</cellbytelabel> <%=nVal%></td>
<%
fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
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
				<%=fb.hidden("fp",fp)%>
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
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%> 
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="5%">&nbsp;</td>
			<td width="15%"><cellbytelabel id="2">C&oacute;digo</cellbytelabel></td>
			<td width="60%"><cellbytelabel id="8">Descripci&oacute;n</cellbytelabel></td>
			<td width="20%"><cellbytelabel id="9">Rango</cellbytelabel></td>
			<td width="10%">&nbsp;</td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
<%=fb.hidden("code"+i,cdo.getColValue("code"))%>
<%=fb.hidden("desc"+i,cdo.getColValue("name"))%>
<%
if (fp.equalsIgnoreCase("diag") || fp.equalsIgnoreCase("rCatDiag"))//referencia diagnostico--paciente
	{%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setCategoria(<%=i%>)" style="cursor:pointer">  
		<% } else { %>
<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
	<%}%>
			<td align="right"><%=preVal + i%>&nbsp;</td>
			<td><%=cdo.getColValue("code")%></td>
			<td><%=cdo.getColValue("name")%></td>
			<td><%=cdo.getColValue("rango")%></td>
			<td align="center">
<%
if(!fp.equalsIgnoreCase("diag") && !fp.equalsIgnoreCase("rCatDiag")){
%>
			<authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("code")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel id="10">Editar</cellbytelabel></a></authtype>
<%
}
%>
			</td>
		</tr>
<%
}
%>
		</table>
	<%=fb.formEnd(true)%>
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
				<%=fb.hidden("fp",fp)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel id="5">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel id="6">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="7">hasta</cellbytelabel> <%=nVal%></td>
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
				<%=fb.hidden("fp",fp)%>
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
} else throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
//} else throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
%>