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
cxc90061
cxc90062
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

	String codigo = request.getParameter("codigo");
	String tipo = request.getParameter("tipo");
	String cobrador = request.getParameter("cobrador");
	String nombre = request.getParameter("nombre");
	String estado = request.getParameter("estado");
	if (codigo == null) codigo = "";
	if (tipo == null) tipo = "";
	if (cobrador == null) cobrador = "";
	if (nombre == null) nombre = "";
	if (estado == null) estado = "";

	if (!codigo.trim().equals("")) { sbFilter.append(" and upper(a.codigo) like '"); sbFilter.append(codigo.toUpperCase()); sbFilter.append("%'"); }
	if (!tipo.trim().equals("")) { sbFilter.append(" and a.tipo_cobrador = '"); sbFilter.append(tipo.toUpperCase()); sbFilter.append("'"); }
	if (!estado.trim().equals("")) { sbFilter.append(" and a.estado = '"); sbFilter.append(estado.toUpperCase()); sbFilter.append("'"); }

	if (!cobrador.trim().equals("")) { sbFilter.append(" and upper(decode(a.tipo_cobrador,'E',a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento,'M',''||a.codigo_empresa,' ')) like '"); sbFilter.append(cobrador); sbFilter.append("%'"); }
	if (!nombre.trim().equals("")) { sbFilter.append(" and upper(a.nombre_cobrador) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
	//if (sbFilter.length() > 0) sbFilter.replace(0,4," where");

	sbSql.append("select a.codigo, a.tipo_cobrador, decode(a.provincia,null,' ',''||a.provincia) as provincia, nvl(a.sigla,' ') as sigla, decode(a.tomo,null,' ',''||a.tomo) as tomo, decode(a.asiento,null,' ',''||a.asiento) as asiento, decode(a.codigo_empresa,null,' ',''||a.codigo_empresa) as codigo_empresa, nvl(a.encargado_empresa,' ') as encargado_empresa, decode(a.compania,null,' ',''||a.compania) as compania, nvl(a.nombre_cobrador,' ') as nombre_cobrador, decode(a.emp_id,null,' ',''||a.emp_id) as emp_id, decode(a.tipo_cobrador,'E','EMPLEADO','M','EMPRESA',a.tipo_cobrador) as tipo, decode(a.tipo_cobrador,'E',a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento,'M',''||a.codigo_empresa,' ') as codigo_cobrador,  decode(a.estado,'A','ACTIVO','I','INACTIVO') estado from tbl_cxc_cobrador a where a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(sbFilter);
	sbSql.append(" order by 2, 1");
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from tbl_cxc_cobrador a where compania = "+session.getAttribute("_companyId")+sbFilter);

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
document.title = 'Analistas / Cobradores - '+document.title;
function add(){abrir_ventana('../cxc/analista_config.jsp');}
function edit(id,tipo){abrir_ventana('../cxc/analista_config.jsp?mode=edit&id='+id+'&tipo='+tipo);}
function printList(){abrir_ventana('../cxc/print_list_analista.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>');}
function saveTipoCobranza(id,tipo){abrir_ventana('../cxc/reg_analista_tipo_cobranza.jsp?id='+id+'&tipo='+tipo);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CUENTAS POR COBRAR - ANALISTAS / COBRADORES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td align="right">&nbsp;<authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nuevo Analista / Cobrador ]</a></authtype></td>
	</tr>
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextFilter">
<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<td width="13%">
					C&oacute;digo
					<%=fb.intBox("codigo","",false,false,false,5)%>
				</td>
				<td width="20%">
					Tipo
					<%=fb.select("tipo","E=EMPLEADO,M=EMPRESA",tipo,false,false,0,null,null,null,null,"T")%>
				</td>

				<td width="7%">
				  	Estado:&nbsp;
				<%=fb.select("estado","A=ACTIVO,I=INACTIVO",estado,false,false,0,"Text10",null,null,null,"T")%>
				</td>

				<td width="27%">
					C&oacute;d. Cobrador
					<%=fb.textBox("cobrador","",false,false,false,16)%>
				</td>
				<td width="33%">
					Cobrador
					<%=fb.textBox("nombre","",false,false,false,30)%>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("cobrador",cobrador)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("estado",estado)%>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("cobrador",cobrador)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("estado",estado)%>
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
		<table align="center" width="100%" cellpadding="0" cellspacing="1" id="list" class="sortable" exclude="4,5">
		<tr class="TextHeader" align="center">
			<td width="7%">C&oacute;digo</td>
			<td width="10%">Tipo</td>
			<td width="11%">C&oacute;d. Cobrador</td>
			<td width="40%">Nombre Cobrador</td>
			<td width="12%">Estado</td>
			<td width="12%">Tipo Cobranza</td>
			<td width="8%">&nbsp;</td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="right"><%=cdo.getColValue("codigo")%></td>
			<td align="center"><%=cdo.getColValue("tipo")%></td>
			<td><%=cdo.getColValue("codigo_cobrador")%></td>
			<td><%=cdo.getColValue("nombre_cobrador")%></td>
				<td><%=cdo.getColValue("estado")%></td>
			<td align="center">&nbsp;<authtype type='50'><a href="javascript:saveTipoCobranza(<%=cdo.getColValue("codigo")%>,'<%=cdo.getColValue("tipo_cobrador")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Actualizar</a></authtype></td>
			<td align="center">&nbsp;<authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("codigo")%>,'<%=cdo.getColValue("tipo_cobrador")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></authtype></td>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("cobrador",cobrador)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("estado",estado)%>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("cobrador",cobrador)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("estado",estado)%>
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