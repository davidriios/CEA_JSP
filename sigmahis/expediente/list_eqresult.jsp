<%@ page errorPage="../../error.jsp"%>
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
String eqType = request.getParameter("eqType");
String pacId = request.getParameter("pacId");
String pacName = request.getParameter("pacName");
String admision = request.getParameter("admision");
String dType = request.getParameter("dType");
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");
if (eqType == null) eqType = "GLU";
if (pacId == null) pacId = "";
if (pacName == null) pacName = "";
if (admision == null) admision = "";
if (dType == null) dType = "processed_date";
if (fDate == null) fDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
if (tDate == null) tDate = fDate;

if (request.getMethod().equalsIgnoreCase("GET")) {

	int recsPerPage = 100;
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

	if (!pacId.trim().equals("")) { sbFilter.append(" and z.pac_id = "); sbFilter.append(pacId); }
	if (!pacName.trim().equals("")) { sbFilter.append(" and exists (select null from vw_adm_paciente where pac_id = z.pac_id and nombre_paciente like '%"); sbFilter.append(pacName); sbFilter.append("%')"); }
	if (!admision.trim().equals("")) { sbFilter.append(" and z.admision = "); sbFilter.append(admision); }
	if (!fDate.trim().equals("")) { sbFilter.append(" and trunc(z."); sbFilter.append(dType); sbFilter.append(") >= to_date('"); sbFilter.append(fDate); sbFilter.append("','dd/mm/yyyy')"); }
	if (!tDate.trim().equals("")) { sbFilter.append(" and trunc(z."); sbFilter.append(dType); sbFilter.append(") <= to_date('"); sbFilter.append(tDate); sbFilter.append("','dd/mm/yyyy')"); }

	if (request.getParameter("pacId") != null) {

		sbSql.append("select z.id, z.pac_id, z.admision, to_char(z.message_date,'dd/mm/yyyy hh24:mi') as result_date, to_char(z.processed_date,'dd/mm/yyyy hh24:mi') as sync_date");
		sbSql.append(", (select nombre_paciente from vw_adm_paciente where pac_id = z.pac_id) as nombre_paciente");
		sbSql.append(" from tbl_int_eqresult z where z.eq_type = '");
		sbSql.append(eqType);
		sbSql.append("'");
		sbSql.append(sbFilter);
		sbSql.append(" order by z.processed_date desc");

		StringBuffer sbTmp = new StringBuffer();
		sbTmp.append("select * from (select rownum as rn, a.* from (");
		sbTmp.append(sbSql);
		sbTmp.append(") a) where rn between ");
		sbTmp.append(previousVal);
		sbTmp.append(" and ");
		sbTmp.append(nextVal);
		al = SQLMgr.getDataList(sbTmp.toString());

		sbTmp = new StringBuffer();
		sbTmp.append("select count(*) from (");
		sbTmp.append(sbSql);
		sbTmp.append(")");
		rowCount = CmnMgr.getCount(sbTmp.toString());

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
<%@ include file="../../common/nocache.jsp"%>
<%@ include file="../../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Resultados de Equipos - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function viewDetail(id){showPopWin('../expediente/list_eqresult_det.jsp?id='+id,winWidth*.75,winHeight*.75,null,null,'');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - RESULTADOS DE EQUIPOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right">&nbsp;</td>
</tr>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("searchMain",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<tr class="TextFilter">
	<td>
		<%=fb.select("eqType","GLU=GLUCOMETRO",eqType,false,false,0,"Text10",null,null,null,null)%>
		<cellbytelabel>Paciente</cellbytelabel>
		<%=fb.textBox("pacId",pacId,false,false,false,10,null,null,null)%>
		<%=fb.textBox("pacName",pacName,false,false,false,30,null,null,null)%>
		<cellbytelabel>Admisi&oacute;n</cellbytelabel>
		<%=fb.textBox("admision",admision,false,false,false,10,null,null,null)%>
		<cellbytelabel>Fecha</cellbytelabel>
		<%=fb.select("dType","message_date=RESULTADO,processed_date=SINCRONIZACION",dType,false,false,0,"Text10",null,null,null,null)%>
		<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="2"/>
		<jsp:param name="nameOfTBox1" value="fDate"/>
		<jsp:param name="valueOfTBox1" value="<%=fDate%>"/>
		<jsp:param name="nameOfTBox2" value="tDate"/>
		<jsp:param name="valueOfTBox2" value="<%=tDate%>"/>
		<jsp:param name="clearOption" value="true"/>
		</jsp:include>
		<%=fb.submit("go","Ir")%>
	</td>
</tr>
<%=fb.formEnd()%>
<tr>
	<td align="right"><% if (request.getParameter("pacId") != null) { %><!--<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>--><% } %>&nbsp;</td>
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
<%=fb.hidden("eqType",eqType)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("pacName",pacName)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("dType",dType)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
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
<%=fb.hidden("eqType",eqType)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("pacName",pacName)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("dType",dType)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="10%">ID</td>
			<td width="45%">Paciente</td>
			<td width="10%">Admisi&oacute;n</td>
			<td width="15%">F. Resultado</td>
			<td width="15%">F. Sincronizaci&oacute;n</td>
			<td width="5%">&nbsp;</td>
		</tr>
<% if (request.getParameter("pacId") == null) { %>
		<tr class="TextRow01 RedText SpacingTextBold" align="center">
			<td colspan="6"><br>INTRODUZCA PARAMETROS DE BUSQUEDA<br><br></td>
		</tr>
<% } else if (al.size() == 0) { %>
		<tr class="TextRow01 RedText SpacingTextBold" align="center">
			<td colspan="6"><br>BUSQUEDA SIN RESULTADOS<br><br></td>
		</tr>
<% } %>
<%
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("id")%></td>
			<td>[<%=cdo.getColValue("pac_id")%>] <%=cdo.getColValue("nombre_paciente")%></td>
			<td align="center"><%=cdo.getColValue("admision")%></td>
			<td align="center"><%=cdo.getColValue("result_date")%></td>
			<td align="center"><%=cdo.getColValue("sync_date")%></td>
			<td align="center"><a href="javascript:viewDetail(<%=cdo.getColValue("id")%>)" class="Link00Bold">VER DETALLE</a></td>
		</tr>
<% } %>
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
<%=fb.hidden("eqType",eqType)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("pacName",pacName)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("dType",dType)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
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
<%=fb.hidden("eqType",eqType)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("pacName",pacName)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("dType",dType)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
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