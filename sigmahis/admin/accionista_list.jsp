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
String status = request.getParameter("status");
String codigo = request.getParameter("codigo");
String nombre = request.getParameter("nombre");
String apellido = request.getParameter("apellido");
String identificacion = request.getParameter("identificacion"); 
String fg = request.getParameter("fg"); 

if (status == null) status = "";
if (codigo == null) codigo = "";
if (nombre == null) nombre = "";
if (apellido == null) apellido = "";
if (fg == null) fg = "";

if (identificacion == null) identificacion = ""; 
if (!status.equals("")) { sbFilter.append(" and a.estado='"); sbFilter.append(status); sbFilter.append("'"); }
if (!codigo.equals("")) { sbFilter.append(" and upper(a.codigo) like '%"); sbFilter.append(codigo.toUpperCase()); sbFilter.append("%'"); }
if (!nombre.equals("")) { sbFilter.append(" and upper(a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre)) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
if (!apellido.equals("")) { sbFilter.append(" and upper(a.primer_apellido||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_de_casada,null,'',' '||a.apellido_de_casada))) like '%"); sbFilter.append(apellido.toUpperCase()); sbFilter.append("%'"); }
if (!identificacion.equals("")) { sbFilter.append(" and upper(a.identificacion) like '%"); sbFilter.append(identificacion.toUpperCase()); sbFilter.append("%'"); }

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

	sbSql.append("select a.codigo, a.ruc as identificacion, a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre) as nombre, a.primer_apellido||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_de_casada,null,'',' '||a.apellido_de_casada)) as apellido,a.estado from tbl_cxc_cliente_particular a where tipo_cliente in ( select column_value  from table( select split((select param_value from tbl_sec_comp_param where compania =a.compania and param_name='POS_TIPO_CLTE_");
	sbSql.append(fg);
	sbSql.append("'),',') from dual  ))  ");
	sbSql.append(" and compania = "); 
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(sbFilter);
	sbSql.append(" order by 4,3");
	if(request.getParameter("status")!= null)
	{ 
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+") ");
	}

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
document.title = ' Accionistas  - Junta Direcctiva - '+document.title;

function add(){abrir_ventana('../admin/accionista_config.jsp?fg=<%=fg%>');}
function edit(id){abrir_ventana('../admin/accionista_config.jsp?fg=<%=fg%>&mode=edit&id='+id);}
function printList(type){
 abrir_ventana('../admin/print_list_accionista.jsp?fg=<%=fg%>&appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CLINICA - ADMISION - MANTENIMIENTOS - MEDICO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;
		<authtype type='3'><a href="javascript:add()" class="Link00">[ Nuevo Registro ]</a></authtype>
	</td>
</tr>
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fg",fg)%>
		<tr class="TextFilter">
			<td width="12%">
				<cellbytelabel id="1">Codigo</cellbytelabel><br>
				<%=fb.textBox("codigo","",false,false,false,15,"Text10",null,null)%>
			</td>
			<td width="18%">
				<cellbytelabel id="2">Nombre</cellbytelabel><br>
				<%=fb.textBox("nombre","",false,false,false,30,"Text10",null,null)%>
			</td>
			<td width="18%">
				<cellbytelabel id="3">Apellido</cellbytelabel><br>
				<%=fb.textBox("apellido","",false,false,false,30,"Text10",null,null)%>
			</td>
			<td width="13%">
				<cellbytelabel id="4">Identificaci&oacute;n/Cedula/Pas.</cellbytelabel><br>
				<%=fb.textBox("identificacion","",false,false,false,20,"Text10",null,null)%>
			</td> 
			<td width="14%">
				<cellbytelabel id="6">Estado</cellbytelabel><br>
				<%=fb.select("status","A=ACTIVO,I=INACTIVO",status,false,false,0,"Text10",null,null,null,"T")%>
				<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("identificacion",identificacion)%>
<%=fb.hidden("fg",fg)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel id="8">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="9">Registros desde</cellbytelabel>  <%=pVal%><cellbytelabel id="10">hasta</cellbytelabel> <%=nVal%></td>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("identificacion",identificacion)%>
<%=fb.hidden("fg",fg)%>
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
		<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="list">
		<tr class="TextHeader" align="center">
			<td width="12%"><cellbytelabel id="1">Codigo</cellbytelabel></td>
			<td width="18%"><cellbytelabel id="2">Nombre</cellbytelabel></td>
			<td width="18%"><cellbytelabel id="3">Apellido</cellbytelabel></td>
			<td width="13%"><cellbytelabel id="4">Identificaci&oacute;n</cellbytelabel></td>
			<td width="25%"><cellbytelabel id="5">&nbsp;</cellbytelabel></td>
			<td width="8%"><cellbytelabel id="6">Estado</cellbytelabel></td>
			<td width="6%">&nbsp;</td>
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
			<td><%=cdo.getColValue("nombre")%></td>
			<td><%=cdo.getColValue("apellido")%></td>
			<td><%=cdo.getColValue("identificacion")%></td>
			<td>&nbsp;</td>
			<td align="center"><%=(cdo.getColValue("estado").equalsIgnoreCase("A"))?"Activo":"Inactivo"%></td>
			<td align="center"><authtype type='4'><a href="javascript:edit('<%=cdo.getColValue("codigo")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel id="11">Editar</cellbytelabel></a></authtype></td>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("identificacion",identificacion)%>
<%=fb.hidden("fg",fg)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel id="8">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="9">Registros desde</cellbytelabel>  <%=pVal%><cellbytelabel id="10">hasta</cellbytelabel> <%=nVal%></
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("identificacion",identificacion)%>
<%=fb.hidden("fg",fg)%>
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