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
cxc90063---Asignacion de cuenta a cobrador
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
String docType = request.getParameter("docType");

if (docType == null) docType = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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

	String docNo = request.getParameter("docNo");
	String paciente = request.getParameter("paciente");
	String docDate = request.getParameter("docDate");
	String cobrador = request.getParameter("cobrador");
	String tipo = request.getParameter("tipo");
	String assignDate = request.getParameter("assignDate");
	if (docNo == null) docNo = "";
	if (paciente == null) paciente = "";
	if (docDate == null) docDate = "";
	if (cobrador == null) cobrador = "";
	if (tipo == null) tipo = "";
	if (assignDate == null) assignDate = "";

	if (!docNo.trim().equals("")) { sbFilter.append(" and upper(a.codigo) like '"); sbFilter.append(docNo.toUpperCase()); sbFilter.append("%'"); }
	if (!paciente.trim().equals("")) { sbFilter.append(" and upper(b.nombre_paciente) like '%"); sbFilter.append(paciente.toUpperCase()); sbFilter.append("%'"); }
	if (!docDate.trim().equals("")) { sbFilter.append(" and a.fecha = to_date('"); sbFilter.append(docDate); sbFilter.append("','dd/mm/yyyy')"); }
	if (!tipo.trim().equals("")) { sbFilter.append(" and a.tipo_cobro = "); sbFilter.append(tipo); }
	if (!assignDate.trim().equals("")) { sbFilter.append(" and a.fecha_asignacion = to_date('"); sbFilter.append(assignDate); sbFilter.append("','dd/mm/yyyy')"); }

	sbSql = new StringBuffer();
	if (docType.trim().equals("") || docType.equalsIgnoreCase("F"))
	{
		sbSql.append("select 'F' as doc_type, a.fecha, a.codigo, 0 as anio, to_char(a.fecha,'dd/mm/yyyy') as doc_date, decode(a.cobrador,null,' ',(select nombre_cobrador from tbl_cxc_cobrador where codigo = a.cobrador)) as cobrador, decode(a.tipo_cobro,null,' ',(select descripcion from tbl_cxc_tipo_analista where tipo = a.tipo_cobro)) as tipo_cobro, nvl(to_char(a.fecha_asignacion,'dd/mm/yyyy'),' ') as fecha_asignacion, nvl(b.nombre_paciente,' ') as paciente from tbl_fac_factura a, vw_adm_paciente b where a.compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		if (!cobrador.trim().equals("")) { sbSql.append(" and a.cobrador = "); sbSql.append(cobrador); }
		sbSql.append(" and a.pac_id = b.pac_id(+)");
		sbSql.append(" and a.facturar_a <> 'O' and a.estatus <> 'A' ");
		sbSql.append(sbFilter);
	}
	/*if (docType.trim().equals("") || docType.equalsIgnoreCase("R"))
	{
		if (docType.trim().equals("")) sbSql.append(" union all ");
		sbSql.append("select 'R' as doc_type, a.fecha, ''||a.codigo as codigo, a.anio, to_char(a.fecha,'dd/mm/yyyy') as doc_date, decode(a.cobrador,null,' ',(select nombre_cobrador from tbl_cxc_cobrador where codigo = a.cobrador and compania = a.compania)) as cobrador, decode(a.tipo_cobro,null,' ',(select descripcion from tbl_cxc_tipo_analista where tipo = a.tipo_cobro)) as tipo_cobro, nvl(to_char(a.fecha_asignacion,'dd/mm/yyyy'),' ') as fecha_asignacion, nvl(b.nombre_paciente,' ') as paciente from tbl_fac_remanente a, vw_adm_paciente b where a.compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		if (!cobrador.trim().equals("")) { sbSql.append(" and a.cobrador = "); sbSql.append(cobrador); }
		sbSql.append(" and a.pac_id = b.pac_id(+)");
		sbSql.append(sbFilter);
	}*/
	sbSql.append(" order by 2 desc");
	if (request.getParameter("docType") != null)
	{
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) count from ("+sbSql.toString()+")");
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
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Asignación de Cobradores - '+document.title;
function assign(docType,id,anio){abrir_ventana('../cxc/asignacion_cobrador_config.jsp?docType='+docType+'&id='+id+'&anio='+anio);}
function view(docType,id,anio){abrir_ventana('../cxc/asignacion_cobrador_config.jsp?mode=view&docType='+docType+'&id='+id+'&anio='+anio);}
function printList(){abrir_ventana('../cxc/print_list_asignacion_cobrador.jsp?docType=<%=docType%>&cobrador=<%=cobrador%>&appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CUENTAS POR COBRAR - ASIGNACION DE COBRADORES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<td width="23%">
				Tipo Doc.
				<%=fb.select("docType","F=FACTURA",docType,false,false,0,null,null,null,null,"T")%>
			</td>
			<td width="22%">
				No. Doc.
				<%=fb.textBox("docNo","",false,false,false,12,12)%>
			</td>
			<td width="31%">
				Paciente
				<%=fb.textBox("paciente","",false,false,false,30,30)%>
			</td>
			<td width="24%">
				Fecha
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="nameOfTBox1" value="docDate"/>
				<jsp:param name="valueOfTBox1" value="<%=docDate%>"/>
				<jsp:param name="clearOption" value="true"/>
				</jsp:include>
			</td>
		</tr>
		<tr class="TextFilter">
			<td colspan="2">
				Cobrador
				<%=fb.select(ConMgr.getConnection(),"select codigo, nombre_cobrador||' - '||codigo, tipo_cobrador from tbl_cxc_cobrador where compania = "+session.getAttribute("_companyId")+" order by 2","cobrador",cobrador,false,false,0,null,null,null,null,"T")%>
			</td>
			<td>
				Tipo
				<%=fb.select(ConMgr.getConnection(),"select tipo, descripcion||' - '||tipo, comision from tbl_cxc_tipo_analista order by 2","tipo",tipo,false,false,0,null,null,null,null,"T")%>
			</td>
			<td>
				Fecha Asigna
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="nameOfTBox1" value="assignDate"/>
				<jsp:param name="valueOfTBox1" value="<%=assignDate%>"/>
				<jsp:param name="clearOption" value="true"/>
				</jsp:include>
				<%=fb.submit("go","Ir")%>
			</td>
<%=fb.formEnd()%>
		</tr>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</td>
</tr>
<tr>
	<td align="right">&nbsp;<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
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
<%=fb.hidden("docType",docType)%>
<%=fb.hidden("docNo",docNo)%>
<%=fb.hidden("paciente",paciente)%>
<%=fb.hidden("docDate",docDate)%>
<%=fb.hidden("cobrador",cobrador)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("assignDate",assignDate)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
<%=fb.hidden("docType",docType)%>
<%=fb.hidden("docNo",docNo)%>
<%=fb.hidden("paciente",paciente)%>
<%=fb.hidden("docDate",docDate)%>
<%=fb.hidden("cobrador",cobrador)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("assignDate",assignDate)%>
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
		<table align="center" width="100%" cellpadding="0" cellspacing="1" id="table" class="sortable" exclude="7">
		<tr class="TextHeader" align="center">
			<td width="7%">Tipo Doc.</td>
			<td width="7%">No. Doc.</td>
			<td width="7%">Fecha</td>
			<td width="24%">Paciente</td>
			<td width="20%">Cobrador</td>
			<td width="15%">Tipo Cobro</td>
			<td width="7%">Fecha Asigna</td>
			<td width="4%">&nbsp;</td>
			<td width="9%">&nbsp;</td>
		</tr>
<% if (al.size() == 0) { %>
		<tr>
			<td colspan="9" class="TextRow01" align="center"><font color="#FF0000">
				<% if (request.getParameter("docType") == null) { %>
				I N T R O D U Z C A &nbsp; P A R A M E T R O S &nbsp; P A R A &nbsp; B U S Q U E D A
				<% } else { %>
				N O &nbsp; H A Y &nbsp; R E G I S T R O S &nbsp; E N C O N T R A D O S
				<% } %>
			</font></td>
		</tr>
<% } %>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	String type = "FACTURA";
	if (cdo.getColValue("doc_type").equalsIgnoreCase("R")) type = "REMANENTE";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" align="center">
			<td><%=type%></td>
			<td><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("doc_date")%></td>
			<td align="left"><%=cdo.getColValue("paciente")%></td>
			<td align="left"><%=cdo.getColValue("cobrador")%></td>
			<td align="left"><%=cdo.getColValue("tipo_cobro")%></td>
			<td><%=cdo.getColValue("fecha_asignacion")%></td>
			<td align="center"><authtype type='1'><a href="javascript:view('<%=cdo.getColValue("doc_type")%>','<%=cdo.getColValue("codigo")%>',<%=cdo.getColValue("anio")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Ver</a></authtype>&nbsp;</td>
			<td align="center"><% if (cdo.getColValue("fecha_asignacion").trim().equals("")) { %><authtype type='8'><a href="javascript:assign('<%=cdo.getColValue("doc_type")%>','<%=cdo.getColValue("codigo")%>',<%=cdo.getColValue("anio")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Asignar</a></authtype><% } else { %><authtype type='50'><a href="javascript:assign('<%=cdo.getColValue("doc_type")%>','<%=cdo.getColValue("codigo")%>',<%=cdo.getColValue("anio")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Re-Asignar</a></authtype><% } %>&nbsp;</td>
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
<%=fb.hidden("docType",docType)%>
<%=fb.hidden("docNo",docNo)%>
<%=fb.hidden("paciente",paciente)%>
<%=fb.hidden("docDate",docDate)%>
<%=fb.hidden("cobrador",cobrador)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("assignDate",assignDate)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
<%=fb.hidden("docType",docType)%>
<%=fb.hidden("docNo",docNo)%>
<%=fb.hidden("paciente",paciente)%>
<%=fb.hidden("docDate",docDate)%>
<%=fb.hidden("cobrador",cobrador)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("assignDate",assignDate)%>
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