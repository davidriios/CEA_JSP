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
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fp = request.getParameter("fp");
String index = request.getParameter("index");
String codigo = request.getParameter("codigo");
String nombre = request.getParameter("nombre");
String nacionalidad = request.getParameter("nacionalidad");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (index != null) index = "";
if (codigo == null) codigo = "";
if (nombre == null) nombre = "";
if (nacionalidad == null) nacionalidad = "";

if (!codigo.trim().equals("")) { sbFilter.append(" and upper(codigo) like '%"); sbFilter.append(codigo.toUpperCase()); sbFilter.append("%'"); }
if (!nombre.trim().equals("")) { sbFilter.append(" and upper(nombre) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
if (!nacionalidad.trim().equals("")) { sbFilter.append(" and upper(nacionalidad) like '%"); sbFilter.append(nacionalidad.toUpperCase()); sbFilter.append("%'"); }

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

	sbSql.append("select codigo, nombre, nacionalidad from tbl_sec_pais where codigo is not null");
	sbSql.append(sbFilter);
	sbSql.append(" order by codigo");
	al = SQLMgr.getDataList(sbSql.toString());
	rowCount = CmnMgr.getCount("select count(*) from tbl_sec_pais where codigo is not null"+sbFilter.toString());

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
document.title = 'Lista de Nacionalidad - '+document.title;

function returnValue(k)
{
	var code=eval('document.result.codigo'+k).value;
	var name=eval('document.result.nombre'+k).value;
	var nac=eval('document.result.nacionalidad'+k).value;
<%
if (fp.equalsIgnoreCase("paciente_nac"))
{
%>
	window.opener.document.form0.nacionalCode.value=code;
	window.opener.document.form0.nacional.value=nac;
	window.close();
<%
}
else if (fp.equalsIgnoreCase("paciente_conyu_nac"))
{
%>
	window.opener.document.form1.conyuNacionalCode.value=code;
	window.opener.document.form1.conyuNacional.value=nac;
	window.close();
<%
}
else if (fp.equalsIgnoreCase("paciente_custodio"))
{
%>
	window.opener.document.form0.nacionalCode.value=code;
	window.opener.document.form0.nacional.value=nac;
	window.close();
<%
}
%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE PAIS / NACIONALIDAD"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("search00",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
		<tr class="TextFilter">
			<td width="20%">
				<cellbytelabel>C&oacute;digo</cellbytelabel>
				<%=fb.textBox("codigo","",false,false,false,10,"Text10",null,null)%>
			</td>
			<td width="40%">
				<cellbytelabel>Pa&iacute;s</cellbytelabel>
				<%=fb.textBox("nombre","",false,false,false,30,"Text10",null,null)%>
			</td>
			<td width="40%">
				<cellbytelabel>Nacionalidad</cellbytelabel>
				<%=fb.textBox("nacionalidad","",false,false,false,30,"Text10",null,null)%>
				<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
			</td>
		</tr>
<%=fb.formEnd()%>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+request.getServletPath());%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("nacionalidad",nacionalidad)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+request.getServletPath());%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("nacionalidad",nacionalidad)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
		<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="list">
		<tr class="TextHeader" align="center">
			<td width="20%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="40%"><cellbytelabel>Pa&iacute;s</cellbytelabel></td>
			<td width="40%"><cellbytelabel>Nacionalidad</cellbytelabel></td>
		</tr>
<%fb = new FormBean("result",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
		<%=fb.hidden("nacionalidad"+i,cdo.getColValue("nacionalidad"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:returnValue(<%=i%>)" style="cursor:pointer">
			<td><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("nombre")%></td>
			<td><%=cdo.getColValue("nacionalidad")%></td>
		</tr>
<%
}
%>
<%=fb.formEnd()%>
		</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("bottomPrevious",request.getContextPath()+request.getServletPath());%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("nacionalidad",nacionalidad)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+request.getServletPath());%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("nacionalidad",nacionalidad)%>
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