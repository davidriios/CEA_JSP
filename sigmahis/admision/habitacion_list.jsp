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
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();

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

	String codigo = request.getParameter("codigo");
	String descripcion = request.getParameter("descripcion");
	String estado = request.getParameter("estado");
	String cds = request.getParameter("cds");
	if (codigo == null) codigo = "";
	if (descripcion == null) descripcion = "";
	if (estado == null) estado = "";
	if (cds == null) cds = "";
	if (!codigo.trim().equals("")) { sbFilter.append(" and upper(codigo) like '%"); sbFilter.append(codigo.toUpperCase()); sbFilter.append("%'"); }
	if (!descripcion.trim().equals("")) {  sbFilter.append(" and upper(descripcion) like '%"); sbFilter.append(descripcion.toUpperCase()); sbFilter.append("%'"); }
	if (!estado.trim().equals("")) {  sbFilter.append(" and estado_habitacion = '"); sbFilter.append(estado.toUpperCase()); sbFilter.append("'"); }
	if (!cds.trim().equals("")) {  sbFilter.append(" and unidad_admin = "); sbFilter.append(cds);}	
	if (sbFilter.length() > 0) sbFilter.replace(0, 4, " where");
	sbSql = new StringBuffer();
	sbSql.append("select codigo, descripcion, compania, estado_habitacion as estado,(select descripcion from tbl_cds_centro_servicio where codigo =unidad_admin) descCds from tbl_sal_habitacion");
	sbSql.append(sbFilter);
	sbSql.append(" order by unidad_admin, descripcion");
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from tbl_sal_habitacion"+sbFilter);

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
document.title='Habitación - '+document.title;
function add(){abrir_ventana('../admision/habitacion_config.jsp');}
function edit(code,compId){abrir_ventana('../admision/habitacion_config.jsp?mode=edit&code='+code+'&compId='+compId);}
function printList(){abrir_ventana('../admision/print_list_habitacion.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>');}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,300);}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CLÍNICA - ADMISIÓN - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right"><authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel id="1">Registrar Nueva Habitaci&oacute;n</cellbytelabel> ]</a></authtype></td>
</tr>
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<td width="50%">
				<cellbytelabel>Sala o Secci&oacute;n</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select distinct a.codigo, a.descripcion, a.codigo from tbl_cds_centro_servicio a, tbl_sal_habitacion b where a.estado='A' and a.codigo=b.unidad_admin order by a.codigo","cds",cds,"T")%>
				<cellbytelabel id="2">C&oacute;digo</cellbytelabel>
				<%=fb.textBox("codigo",codigo,false,false,false,30)%>
			</td>
			<td width="30%">
				<cellbytelabel id="3">Descripci&oacute;n</cellbytelabel>
				<%=fb.textBox("descripcion",descripcion,false,false,false,30)%>
			</td>
			<td width="25%">
				<cellbytelabel id="4">Estado</cellbytelabel>
				<%=fb.select("estado","D=DISPONIBLE,U=EN USO,I=INACTIVO,M=MANTENIMIENTO,R=RESERVADO",estado,"S")%>
				<%=fb.submit("go","Ir")%>
			</td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel id="5">Imprimir Lista</cellbytelabel> ]</a></authtype></td>
</tr>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("cds",cds)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel id="6">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="7">Registros desde</cellbytelabel>  <%=pVal%><cellbytelabel id="8">hasta</cellbytelabel> <%=nVal%></td>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("cds",cds)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
	<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="15%"><cellbytelabel id="2">C&oacute;digo</cellbytelabel></td>
			<td width="30%"><cellbytelabel id="3">Descripci&oacute;n</cellbytelabel></td>
			<td width="25%"><cellbytelabel id="3">Centro de Servicio</cellbytelabel></td>
			<td width="20%"><cellbytelabel id="4">Estado</cellbytelabel></td>
			<td width="10%">&nbsp;</td>
		</tr>
<%
String estadoVar = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);

	if (cdo.getColValue("estado").equalsIgnoreCase("D")) estadoVar = "DISPONIBLE";
	else if (cdo.getColValue("estado").equalsIgnoreCase("U")) estadoVar = "EN USO";
	else if (cdo.getColValue("estado").equalsIgnoreCase("I")) estadoVar = "INACTIVO";
	else if (cdo.getColValue("estado").equalsIgnoreCase("M")) estadoVar = "MANTENIMIENTO";
	else if (cdo.getColValue("estado").equalsIgnoreCase("R")) estadoVar = "RESERVADO";
	else estadoVar = cdo.getColValue("estado");

	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td><%=cdo.getColValue("descCds")%></td>
			<td><%=estadoVar%></td>
			<td align="center"><authtype type='4'><a href="javascript:edit('<%=cdo.getColValue("codigo")%>', <%=cdo.getColValue("compania")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel id="9">Editar</cellbytelabel></a></authtype></td>
		</tr>
<%
}
%>
		</table>
		</div>
		</div>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	</td>
</tr>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("cds",cds)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel id="6">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="7">Registros desde</cellbytelabel> <%=pVal%><cellbytelabel id="8">hasta</cellbytelabel> <%=nVal%></td>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("cds",cds)%>
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
<%
}
%>