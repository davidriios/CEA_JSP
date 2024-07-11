<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
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
String mType = request.getParameter("mType");
String fDate = request.getParameter("fDate");
String cds = request.getParameter("cds");
String room = request.getParameter("room");
String bed = request.getParameter("bed");
String pacId = request.getParameter("pacId");
String admision = request.getParameter("admision");
String interval = request.getParameter("interval");
if (mType == null) mType = "VS";
if (fDate == null) fDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
if (cds == null) cds = "";
if (room == null) room = "";
if (bed == null) bed = "";
if (pacId == null) pacId = "";
if (admision == null) admision = "";
if (interval == null) interval = "15";

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

	if (pacId.equals("") || admision.equals("")) throw new Exception("El Paciente o la Admisión no es válida!");
	sbSql.append("select nombre_paciente from vw_adm_paciente where pac_id = ");
	sbSql.append(pacId);
	CommonDataObject pac = SQLMgr.getData(sbSql);

	if (!cds.trim().equals("")) { sbFilter.append(" and a.cds = "); sbFilter.append(cds); }
	if (!room.trim().equals("")) { sbFilter.append(" and a.room = '"); sbFilter.append(room); sbFilter.append("'"); }
	if (!bed.trim().equals("")) { sbFilter.append(" and a.bed = '"); sbFilter.append(bed); sbFilter.append("'"); }
	if (!pacId.trim().equals("")) { sbFilter.append(" and a.pac_id = "); sbFilter.append(pacId); }
	if (!admision.trim().equals("")) { sbFilter.append(" and exists (select null from tbl_adm_admision z where pac_id = a.pac_id and secuencia = a.admision and adm_root = (select adm_root from tbl_adm_admision where pac_id = z.pac_id and secuencia = "); sbFilter.append(admision); sbFilter.append("))"); }
	if (!fDate.trim().equals("")) { sbFilter.append(" and trunc(a.obx_date) = to_date('"); sbFilter.append(fDate); sbFilter.append("','dd/mm/yyyy')"); }

	sbSql = new StringBuffer();
	sbSql.append("select to_char(trunc(sysdate) + ((level - 1) * ");
	sbSql.append(interval);
	sbSql.append(") / 1440, 'HH24:MI') as hhmm from dual connect by level <= (1440 / ");
	sbSql.append(interval);
	sbSql.append(")");
	StringBuffer sbInterval = new StringBuffer();
	ArrayList alPivot = SQLMgr.getDataList(sbSql);
	for (int j = 0; j < alPivot.size(); j++) {
		CommonDataObject cdo = (CommonDataObject) alPivot.get(j);
		if (j > 0) sbInterval.append(",");
		sbInterval.append("'");
		sbInterval.append(cdo.getColValue("hhmm"));
		sbInterval.append("'");
	}

	sbSql = new StringBuffer();
	sbSql.append("select * from (");//query to get the closest positive diff to the given interval

		sbSql.append("select a.pac_id, a.admision, nvl((select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id),'- SIN CUENTA -') as paciente, a.cds, a.room, a.bed, a.obx_measure, a.obx_measure_desc, a.obx_measure_result as result, trunc(a.obx_date) as obxdate, to_char(trunc(a.obx_date),'dd/mm/yyyy') as obxdate_dsp, a.obxtime, (select descripcion from tbl_cds_centro_servicio where codigo = a.cds) as cds_desc");
		sbSql.append(", row_number() over(partition by a.pac_id, a.admision, a.cds, a.room, a.bed, a.obx_measure, trunc(a.obx_date), a.obxtime order by abs(getDateDifRound(a.obx_date,");
		sbSql.append(interval);
		sbSql.append(",'D'))/*--- min diff ---*/, getDateDifRound(a.obx_date,");
		sbSql.append(interval);
		sbSql.append(",'D') desc/*--- the closest positive min diff ---*/) as priority");
		if (mType.equalsIgnoreCase("VS")) sbSql.append(", (select display_order from tbl_int_measure where code = a.obx_measure) as obx_measure_order");
		else sbSql.append(", null as obx_measure_order");
		sbSql.append(" from tbl_int_measurement_validated a");
		sbSql.append(" where a.status = 'P' and a.measurement_type = '");
		sbSql.append(mType);
		sbSql.append("' and abs(getDateDifRound(a.obx_date,");
		sbSql.append(interval);
		sbSql.append(",'D')) < (");
		sbSql.append(interval);
		sbSql.append(" / 2) * 60/*--- to exclude rounding time to next day ---*/");
		sbSql.append(sbFilter);

	sbSql.append(") where priority = 1/* order by pac_id, admision, obx_measure_order, obx_measure, obxdate, obxtime*/");

	StringBuffer sbSqlFinal = new StringBuffer();
	sbSqlFinal.append("select * from (");
	sbSqlFinal.append(sbSql);
	sbSqlFinal.append(") pivot ( max(result) for obxtime in (");
	sbSqlFinal.append(sbInterval);
	sbSqlFinal.append(") ) order by pac_id, admision, cds, room, bed, obxdate, obx_measure_order, obx_measure");
	al = SQLMgr.getDataList(sbSqlFinal.toString());
	rowCount = 0;//CmnMgr.getCount("select count(*) from ("+sbSqlFinal+")");

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
document.title = 'Resultados de Mediciones x Intervalo - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function printRpt(opt){
var interval=30;
var intervalCol=document.search00.intervalRange.value;
if(intervalCol==0)interval=60;
if(opt==1)abrir_ventana('../expediente/print_measurement_pac_interval.jsp?pacId=<%=pacId%>&admision=<%=admision%>&pacName=<%=IBIZEscapeChars.forURL(pac.getColValue("nombre_paciente"))%>&fDate=<%=fDate%>&interval='+interval+'&intervalCol='+intervalCol);
else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=expediente/rpt_measurement_pac_interval.rptdesign&pPacId=<%=pacId%>&pAdmision=<%=admision%>&pPacName=<%=IBIZEscapeChars.forURL(pac.getColValue("nombre_paciente"))%>&pDate=<%=fDate%>&pInterval='+interval+'&pIntervalCol='+intervalCol+'&pCtrlHeader=true');//&pIntervalCol<%//=IBIZEscapeChars.forURL()%>
}
</script>
<style type="text/css">
.zui-table {
    border: none;
    border-right: solid 1px #DDEFEF;
    border-collapse: separate;
    border-spacing: 0;
    font: normal 13px Arial, sans-serif;
}
.zui-table thead th {
    background-color: #DDEFEF;
    border: none;
    color: #336B6B;
    padding: 10px;
    text-align: left;
    white-space: nowrap;
}
.zui-table tbody td {
    border-bottom: solid 1px #DDEFEF;
    color: #000;
    padding: 10px;
    white-space: nowrap;
}
.zui-table tbody td.group {
    border-top: solid 1px #ff0000;
    border-bottom: solid 1px #ff0000;
    color: #ff0000;
    font-weight:bold;
    padding: 10px;
    white-space: nowrap;
		cursor: pointer;
}
.zui-wrapper {
    position: relative;
}
.zui-scroller {
    margin-left: 196px;
    overflow-x: scroll;
    overflow-y: visible;
    padding-bottom: 5px;
}
.zui-table .zui-sticky-col {
    border-left: solid 1px #DDEFEF;
    border-right: solid 1px #DDEFEF;
    left: 0;
    position: absolute;
    top: auto;
    width: 175px;
}
/*
container -> content -> scroller
wrapper   -> scroller
div.Container
{ position:relative; overflow:scroll; height:0; }
div.ContainerContent
{ position:absolute; overflow; width:100%; }
*/
</style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - RESULTADO DE MEDICIONES X INTERVALO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right">&nbsp;</td>
</tr>
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("mType",mType)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("admision",admision)%>
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextFilter" align="center">
			<td class="Text14">[ <%=pacId%>-<%=admision%> ] &nbsp; <%=pac.getColValue("nombre_paciente")%></td>
		</tr>
		<tr class="TextFilter">
			<td>
				<cellbytelabel>Fecha</cellbytelabel>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="fDate" />
				<jsp:param name="valueOfTBox1" value="<%=fDate%>" />
				</jsp:include>
				<cellbytelabel>Interval</cellbytelabel>
				<%=fb.select("interval","5=5 min,10=10 min,15=15 min,30=30 min,60=1 hora,120=2 horas,180=3 horas,240=4 horas",interval,false,false,0,null,null,null,null,"S")%><!--</br>
				<cellbytelabel>Centro</cellbytelabel>
				<%//=fb.select(ConMgr.getConnection(),"select codigo, codigo||' - '||descripcion from tbl_cds_centro_servicio where compania_unorg = "+session.getAttribute("_companyId")+" and estado = 'A' and si_no = 'S' order by 2","cds",cds,false,false,false,0,"S")%>
				<cellbytelabel>Habitaci&oacuten</cellbytelabel>
				<%//=fb.textBox("room",room,false,false,false,10)%>
				<cellbytelabel>Cama</cellbytelabel>
				<%//=fb.textBox("bed",bed,false,false,false,10)%>-->
				<%=fb.submit("go","Desplegar")%>
			</td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td align="right">
		<%=fb.select("intervalRange","0=DIA COMPLETO (INTERVALO X HORA),1=ANTES DE MEDIODIA (INTERVALO DE 30 MIN),2=DESPUES DE MEDIODIA (INTERVALO DE 30 MIN),-1=ULTIMAS HORAS (INTERVALO DE 30 MIN)","")%>
		<a class="Link00Bold" href="javascript:printRpt(0);">[ <cellbytelabel>Imprimir EXCEL</cellbytelabel> ]</a>
		<a class="Link00Bold" href="javascript:printRpt(1);">[ <cellbytelabel>Imprimir PDF</cellbytelabel> ]</a>
		&nbsp;
	</td>
</tr>
<%=fb.formEnd()%>
<tr>
	<td class="TableBorder">

<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
<!--<div class="zui-wrapper">-->
<div class="zui-scroller">

<table class="zui-table" align="center" width="100%" cellpadding="1" cellspacing="1">
<thead>
<tr class="TextHeader">
	<th class="zui-sticky-col" width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></th><!--obx3-->
<%
for (int j = 0; j < alPivot.size(); j++) {
	CommonDataObject cdo = (CommonDataObject) alPivot.get(j);
%>
	<th><%=cdo.getColValue("hhmm")%></th>
<% } %>
</tr>
</thead>
<% if (al.size() > 0) { %><tbody><% } %>
<%
String groupBy = "";
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	if (!groupBy.equals(cdo.getColValue("obxdate_dsp")+"-"+cdo.getColValue("cds")+"-"+cdo.getColValue("room")+"-"+cdo.getColValue("bed"))) {
%>
<tr class="TextRow02">
	<td class="zui-sticky-col group">[ <%=cdo.getColValue("obxdate_dsp")%> &nbsp; :: &nbsp; <%=cdo.getColValue("cds")%>-<%=cdo.getColValue("room")%>-<%=cdo.getColValue("bed")%> ] &nbsp; <%=cdo.getColValue("cds_desc")%></td>
<% for (int j = 0; j < alPivot.size(); j++) { %><td class="group">&nbsp;<!--=====--></td><% } %>
</tr>
<% } %>
<tr class="TextRow01">
	<td class="zui-sticky-col hint hint--right" data-hint="<%=cdo.getColValue("obx_measure")%>"><%=cdo.getColValue("obx_measure_desc")%></td><!--obx3-->
<%
for (int j = 0; j < alPivot.size(); j++) {
	CommonDataObject cdoPivot = (CommonDataObject) alPivot.get(j);
%>
	<td><%=cdo.getColValue("'"+cdoPivot.getColValue("hhmm")+"'","&nbsp;")%></td>
<% } %>
</tr>
<%
	groupBy = cdo.getColValue("obxdate_dsp")+"-"+cdo.getColValue("cds")+"-"+cdo.getColValue("room")+"-"+cdo.getColValue("bed");
}
%>
<% if (al.size() > 0) { %></tbody><% } %>
</table>

</div>
<!--</div>-->
</div>
</div>

	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<% } %>