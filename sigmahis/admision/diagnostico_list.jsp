<%//@ page errorPage="../error.jsp"%>
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
==================================================================================
==================================================================================
*/
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
String codigo = request.getParameter("codigo");
String name = request.getParameter("name");
String nombre = request.getParameter("nombre");
String icd10 = request.getParameter("icd10");
String icdVersion = request.getParameter("icdVersion");

if(request.getMethod().equalsIgnoreCase("GET")) {

	int recsPerPage=100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  if (request.getParameter("searchQuery") != null) {
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }

  if (codigo == null) codigo = "";
  if (name == null) name = "";
  if (nombre == null) nombre = "";
  if (icd10 == null) icd10 = "";
  if (icdVersion == null) icdVersion = "";

	if (!codigo.trim().equals("")) { sbFilter.append(" and upper(z.codigo) like '%"); sbFilter.append(codigo.toUpperCase()); sbFilter.append("%'"); }
	if (!name.trim().equals("")) { sbFilter.append(" and upper(z.nombre) like '%"); sbFilter.append(name.toUpperCase()); sbFilter.append("%'"); }
	if (!nombre.trim().equals("")) { sbFilter.append(" and upper(z.observacion) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
	if (!icd10.trim().equals("")) { sbFilter.append(" and upper(y.codigo_icd10) like '%"); sbFilter.append(icd10.toUpperCase()); sbFilter.append("%'"); }
	if (!icdVersion.trim().equals("")) { sbFilter.append(" and z.icd_version = "); sbFilter.append(icdVersion); }

	sbSql.append("select z.codigo, z.nombre, nvl(z.observacion,' ') as observacion, z.icd_version, nvl(y.codigo_icd10,' ') as codigo_icd10 from tbl_cds_diagnostico z, tbl_cds_diagnostico_icd10map y where z.codigo = y.codigo_icd09(+)");
	sbSql.append(sbFilter);
	sbSql.append(" order by codigo");
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM tbl_cds_diagnostico z, tbl_cds_diagnostico_icd10map y where z.codigo = y.codigo_icd09(+)"+sbFilter);
	
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
document.title = 'Clínica - Diagnóstico - '+document.title;

function add()
{
abrir_ventana('../admision/diagnostico_config.jsp');
}

function edit(id)
{
	abrir_ventana('../admision/diagnostico_config.jsp?mode=edit&id='+id);
}

function  printList()
{
abrir_ventana('../admision/print_list_diagnostico.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="Clínico - Admisión - Mantenimiento - Diagnóstico "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right" colspan="4"><authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel id="1">Registrar Nuevo Diagn&oacute;stico</cellbytelabel> ]</a></authtype>
	</td>
</tr>	
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>	
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<tr class="TextFilter">
			<td>
				<cellbytelabel>ICD<%=fb.select("icdVersion","9,10",icdVersion,false,false,0,null,null,null,null,"T")%></cellbytelabel>
				<%=fb.textBox("codigo",codigo,false,false,false,8,null,null,null)%>
				<cellbytelabel>Equivalente ICD10</cellbytelabel>
				<%=fb.textBox("icd10",icd10,false,false,false,8,null,null,null)%>
				<cellbytelabel>Ingl&eacute;s</cellbytelabel>
				<%=fb.textBox("name",name,false,false,false,45,null,null,null)%>
				<cellbytelabel>Espa&ntilde;ol</cellbytelabel>
				<%=fb.textBox("nombre",nombre,false,false,false,46,null,null,null)%>
				<%=fb.submit("go","Ir")%>
			</td>
		</tr>
<%=fb.formEnd()%>	
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</table>
	</td>
</tr>
<tr>
	<td align="right">
		<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel id="5">Imprimir Lista</cellbytelabel> ]</a></authtype>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<% fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp"); %>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("icd10",icd10)%>
<%=fb.hidden("name",name)%>
<%=fb.hidden("nombre",nombre)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel id="6">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="7">Registros desde</cellbytelabel> <%=pVal%><cellbytelabel id="8">hasta</cellbytelabel> <%=nVal%></td>
<% fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp"); %>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("icd10",icd10)%>
<%=fb.hidden("name",name)%>
<%=fb.hidden("nombre",nombre)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="10%"><cellbytelabel>Versi&oacute;n</cellbytelabel></td>
			<td width="10%"><cellbytelabel>ICD</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Equivalente ICD10</cellbytelabel></td>
			<td width="30%"><cellbytelabel>Ingl&eacute;s</cellbytelabel></td>
			<td width="30%"><cellbytelabel>Espa&ntilde;ol</cellbytelabel></td>
			<td width="10%">&nbsp;</td>
		</tr>
<%
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("icd_version")%></td>
			<td><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("codigo_icd10")%></td>
			<td><%=cdo.getColValue("nombre")%></td>
			<td><%=cdo.getColValue("observacion")%></td>
			<td align="center"><authtype type='4'><a href="javascript:edit('<%=cdo.getColValue("codigo")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel id="9">Editar</cellbytelabel></a></authtype></td>
		</tr>
<% } %>
		</table>	

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<% fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp"); %>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("icd10",icd10)%>
<%=fb.hidden("name",name)%>
<%=fb.hidden("nombre",nombre)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel id="6">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="7">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="8">hasta</cellbytelabel> <%=nVal%></td>
<% fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp"); %>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("icd10",icd10)%>
<%=fb.hidden("name",name)%>
<%=fb.hidden("nombre",nombre)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<% } %>