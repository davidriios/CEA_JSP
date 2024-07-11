<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
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

	String codigo  = "";              // variables para mantener el valor de los campos filtrados en la consulta
	String nombre  = "";
	String estado  = "",reporta="",tipo="";

	if (request.getParameter("code") != null && !request.getParameter("code").trim().equals(""))
	{
		appendFilter += " and upper(a.codigo) like '%"+request.getParameter("code").toUpperCase()+"%'";
		codigo     = request.getParameter("code");        // utilizada para mantener el código del centro
	}
	if (request.getParameter("name") != null && !request.getParameter("name").trim().equals(""))
	{
		appendFilter += " and upper(a.descripcion) like '%"+request.getParameter("name").toUpperCase()+"%'";
		nombre     = request.getParameter("name") ;        // utilizada para mantener el nombre del centro
	}
	if (request.getParameter("estado") != null && !request.getParameter("estado").trim().equals(""))
	{
		appendFilter += " and upper(a.estado) like '%"+request.getParameter("estado").toUpperCase()+"%'";
		estado     = request.getParameter("estado");        // utilizada para mantener el estatus del centro
	}
	if (request.getParameter("reporta") != null && !request.getParameter("reporta").trim().equals(""))
	{
		appendFilter += " and upper(a.reporta_a) ='"+request.getParameter("reporta").toUpperCase()+"'";
		reporta     = request.getParameter("reporta");
	}
	if (request.getParameter("tipo") != null && !request.getParameter("tipo").trim().equals(""))
		{
			appendFilter += " and upper(a.tipo_cds) ='"+request.getParameter("tipo").toUpperCase()+"'";
			tipo     = request.getParameter("tipo");
	}

	sql = "select a.codigo, a.descripcion, decode(a.estado,'A','Activo','I','Inactivo') as estado,decode(a.origen,'C','Centro Servicio','S','Sala / Sección','A','Área','O','Otro origen') origen, a.tipo_cds as tipo, (SELECT DISTINCT nvl(descripcion,' ')  FROM TBL_cds_centro_servicio WHERE codigo=a.reporta_a AND a.reporta_a IS NOT NULL) as unidad from tbl_cds_centro_servicio a where a.compania_unorg="+(String) session.getAttribute("_companyId")+"  "+appendFilter+" order by descripcion";

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);

	rowCount = CmnMgr.getCount("select count(*) from tbl_cds_centro_servicio a where a.compania_unorg="+(String) session.getAttribute("_companyId")+"  "+appendFilter);

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
document.title = 'Administración - Centro de Servicio - '+document.title;

function add()
{
	abrir_ventana('../admin/centroservicio_config.jsp');
}

function edit(id)
{
	abrir_ventana('../admin/centroservicio_config.jsp?mode=edit&id='+id);
}

function printList()
{
	abrir_ventana('../admin/print_list_centroservicio.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}

function setReferences(id)
{
	abrir_ventana('../admin/reg_cds_references.jsp?mode=edit&id='+id);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMINISTRACIÓN - CENTRO DE SERVICIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td align="right">&nbsp;<a href="javascript:add()" class="Link00">[ <cellbytelabel>Registrar Nuevos Centro de Servicio</cellbytelabel> ]</a></td>
	</tr>
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="0" cellspacing="1">
			<tr class="TextFilter">

<%
fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<td width="20%">
					&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.intBox("code",codigo,false,false,false,10)%>
				</td>
				<td width="50%">
					&nbsp;<cellbytelabel>Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("name",nombre,false,false,false,40)%>
					&nbsp;&nbsp;<cellbytelabel>Reporta A</cellbytelabel>:
					<%=fb.intBox("reporta","",false,false,false,10)%>
				</td>
				<td width="30%">
					&nbsp;<cellbytelabel>Estado</cellbytelabel>
					<%=fb.select("estado","A=Activo,I=Inactivo",estado,"T")%>
					&nbsp;&nbsp;<cellbytelabel>Tipo</cellbytelabel>
					<%=fb.select("tipo","I=Interno,E=Externo,T=Tercero",tipo,"T")%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
			</tr>
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
	<tr>
		<td align="right">&nbsp;<a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></td>
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
					<%=fb.hidden("reporta",""+reporta)%>
					<%=fb.hidden("code",codigo)%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("name",nombre)%>

					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
					<%=fb.hidden("reporta",""+reporta)%>
					<%=fb.hidden("code",codigo)%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("name",nombre)%>
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
		<td width="7%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
		<td width="29%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
		<td width="15%"><cellbytelabel>Origen</cellbytelabel></td>
		<td width="22%"><cellbytelabel>Reporta A</cellbytelabel></td>
		<td width="9%"><cellbytelabel>Estado</cellbytelabel></td>
		<td width="9%">&nbsp;</td>
		<td width="9%">&nbsp;</td>
	</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td><%=cdo.getColValue("origen")%></td>
			<td><%=cdo.getColValue("unidad")%></td>

			<td><%=cdo.getColValue("estado")%></td>
			<td align="center">
<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"100030"))
//{
%>			<a href="javascript:edit(<%=cdo.getColValue("codigo")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Editar</cellbytelabel></a>
<%
//}
%>
			</td>
			<td align="center">
			<a href="javascript:setReferences(<%=cdo.getColValue("codigo")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Configuraci&oacute;n</cellbytelabel></a>
			</td>
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
					<%=fb.hidden("reporta",""+reporta)%>
					<%=fb.hidden("code",codigo)%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("name",nombre)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
					<%=fb.hidden("reporta",""+reporta)%>
					<%=fb.hidden("code",codigo)%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("name",nombre)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table><%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>