<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
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
==========================================================================================
==========================================================================================
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
String tr = request.getParameter("tr");
/*
===================================================================================
tr	= 	Tipo de requisicion
===================================================================================
UA	= 	REQUISICION DE MATERIALES Y EQUIPOS DE UNIDADES ADMINISTRATIVAS
UAT = 	REQUISICION DE MATERIALES Y EQUIPOS DE UNIDADES ADMINISTRATIVAS TEMPORALES
SM	=		REQUISICION DE MATERIALES PARA SERVICIOS DE MANTENIMIENTO
EC	=		REQUISICION DE MATERIALES ENTRE COMPAÑIAS
EA	=		REQUISICION DE MATERIALES ENTRE ALMACENES
===================================================================================
*/
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

	String filterTr = "",solicitud_no="",anio="",tipo_solicitud="";
	if(tr.equals("UA")){
	
	filterTr += " where tipo_transferencia = 'U' and codigo_almacen = 1 and estado_solicitud = 'T' and activa = 'S'";
	filterTr += " and unidad_administrativa in ";
		if(session.getAttribute("_ua")!=null) filterTr +=" ("+CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_ua"))+")"; 
		else filterTr +="(-1)";
	filterTr += " and compania = "+session.getAttribute("_companyId");
	} else if(tr.equals("UAT")){
		filterTr = " where tipo_transferencia = 'U'" ;
	} else if(tr.equals("SM")){
		//filterTr = " where tipo_transferencia = 'U' and codigo_almacen = 5 and codigo_almacen_ent != null" ;
		filterTr = " where compania_sol = 1 and estado_solicitud = 'T' and codigo_almacen = 5 and tipo_transferencia in ('U','C')";
	} else if(tr.equals("EC")){
		filterTr = " where compania = "+ session.getAttribute("_companyId") +" and estado_solicitud = 'T' and activa = 'S' and tipo_transferencia = 'C'";
	}  

	if (request.getParameter("solicitud_no") != null && !request.getParameter("solicitud_no").trim().equals(""))
	{
		appendFilter += " and upper(solicitud_no) like '%"+request.getParameter("solicitud_no").toUpperCase()+"%'";
		solicitud_no = request.getParameter("solicitud_no");
	}
	if (request.getParameter("anio") != null && !request.getParameter("anio").trim().equals(""))
	{
		appendFilter += " and upper(anio) like '%"+request.getParameter("anio").toUpperCase()+"%'";
		anio = request.getParameter("anio");
	}
	if (request.getParameter("tipo_solicitud") != null && !request.getParameter("tipo_solicitud").trim().equals(""))
	{
		appendFilter += " and upper(tipo_solicitud) like '%"+request.getParameter("tipo_solicitud").toUpperCase()+"%'";
		tipo_solicitud = request.getParameter("tipo_solicitud");
	}
	
	sql = "select anio, solicitud_no, tipo_solicitud, decode(tipo_solicitud,'D','DIARIA','S','SEMANAL','Q','QUINCENAL','M','MENSUAL') desc_tipo_solicitud, to_char(fecha_documento,'dd/mm/yyyy') fecha_documento, NVL(observacion,' ') observacion, estado_solicitud, DECODE(estado_solicitud,'A','APROBADO','P','PENDIENTE','R','RECHAZADO','N','ANULADO','T','TRAMITE','E','ENTREGADO') desc_estado FROM tbl_inv_solicitud_req "+filterTr+appendFilter;
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from ("+sql+")");

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
document.title = 'Inventario - '+document.title;
function approve(anio, id, tp){abrir_ventana('../inventario/aprove_requisicion.jsp?mode=approve&id='+id+'&anio='+anio+'&tipoSolicitud='+tp+'&tr=<%=tr%>');}
function printList(){abrir_ventana('../inventario/print_list_req_unid_adm.jsp');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
	<%
	if(tr.equals("UA")){
	%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - REQ. MATERIALES Y EQUIPOS DE UNIDADES ADMIN."></jsp:param>
</jsp:include>
	<%
	} else if(tr.equals("UAT")){
	%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - REQ. MATERIALES Y EQUIPOS DE UNIDADES ADMIN. - TEMPORAL"></jsp:param>
</jsp:include>
	<%
	} else if(tr.equals("SM")){
	%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - REQ. MATERIALES PARA SERVICIOS DE MANTENIMIENTO"></jsp:param>
</jsp:include>
	<%
	} else if(tr.equals("EC")){
	%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - REQUISICION DE MATERIALES ENTRE COMPA&Ntilde;IAS"></jsp:param>
</jsp:include>
	<%
	}
	%>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td align="right">&nbsp;</td>
	</tr>
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextFilter">
<%fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("tr",tr)%>
				<td width="34%">
					A&Ntilde;o
					<%=fb.intBox("anio","",false,false,false,30)%>
				</td>
				<td width="33%">
					C&oacute;digo
					<%=fb.intBox("solicitud_no","",false,false,false,30)%>
				</td>
				<td width="33%">
					Tipo Solicitud
					<%=fb.select("tipo_solicitud","D=Diaria,S=Semanal,Q=Quincenal,M=Mensual","")%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>

			</tr>
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
	<tr>
		<td align="right"><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a>&nbsp;
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
				<%=fb.hidden("tr",tr)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("solicitud_no",solicitud_no)%>
				<%=fb.hidden("tipo_solicitud",tipo_solicitud)%>
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
				<%=fb.hidden("tr",tr)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("solicitud_no",solicitud_no)%>
				<%=fb.hidden("tipo_solicitud",tipo_solicitud)%>
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
		<tr class="TextHeader" align="center">
			<td width="5%">&nbsp;</td>
			<td width="15%">A&ntilde;o</td>
			<td width="20%">No. Solicitud</td>
			<td width="20%">Tipo Solicitud</td>
			<td width="20%">Fecha Doc.</td>
			<td width="10%">&nbsp;</td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="right"><%=preVal + i%>&nbsp;</td>
			<td align="center"><%=cdo.getColValue("anio")%></td>
			<td align="center"><%=cdo.getColValue("solicitud_no")%></td>
			<td align="center"><%=cdo.getColValue("desc_tipo_solicitud")%></td>
			<td align="center"><%=cdo.getColValue("fecha_documento")%></td>
			<td align="center">
			<a href="javascript:approve(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("solicitud_no")%>,'<%=cdo.getColValue("tipo_solicitud")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Aprobar</a>
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
				<%=fb.hidden("tr",tr)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("solicitud_no",solicitud_no)%>
				<%=fb.hidden("tipo_solicitud",tipo_solicitud)%>
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
				<%=fb.hidden("tr",tr)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("solicitud_no",solicitud_no)%>
				<%=fb.hidden("tipo_solicitud",tipo_solicitud)%>
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