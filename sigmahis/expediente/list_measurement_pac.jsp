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

	String mType = request.getParameter("mType");
	String fDate = request.getParameter("fDate");
	String tDate = request.getParameter("tDate");
	String pacId = request.getParameter("pacId");
	String admision = request.getParameter("admision");
	String cds = request.getParameter("cds");
	String room = request.getParameter("room");
	String bed = request.getParameter("bed");
	if (mType == null) mType = "VS";
	if (fDate == null) fDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
	if (tDate == null) tDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
	if (cds == null) cds = "";
	if (room == null) room = "";
	if (bed == null) bed = "";

	sbFilter.append(" where z.status = 'P' and z.pac_id = ");
	sbFilter.append(pacId);
	if (!admision.trim().equals("")) { sbFilter.append(" and exists (select null from tbl_adm_admision a where pac_id = z.pac_id and secuencia = z.admision and adm_root = (select adm_root from tbl_adm_admision where pac_id = a.pac_id and secuencia = "); sbFilter.append(admision); sbFilter.append("))"); }
	sbFilter.append(" and z.measurement_type = '");
	sbFilter.append(mType);
	sbFilter.append("'");
	if (!cds.trim().equals("")) { sbFilter.append(" and z.cds = "); sbFilter.append(cds); }
	if (!room.trim().equals("")) { sbFilter.append(" and z.room = '"); sbFilter.append(room); sbFilter.append("'"); }
	if (!bed.trim().equals("")) { sbFilter.append(" and z.bed = '"); sbFilter.append(bed); sbFilter.append("'"); }
	if (!fDate.trim().equals("")) { sbFilter.append(" and trunc(z.obx_date) >= to_date('"); sbFilter.append(fDate); sbFilter.append("','dd/mm/yyyy')"); }
	if (!tDate.trim().equals("")) { sbFilter.append(" and trunc(z.obx_date) <= to_date('"); sbFilter.append(tDate); sbFilter.append("','dd/mm/yyyy')"); }

	sbSql.append("select z.pac_id, z.admision, z.cds, z.room, z.bed, (select nombre_paciente from vw_adm_paciente where pac_id = z.pac_id) as paciente, to_char(z.obx_date,'dd/mm/yyyy') as obxdate, to_char(z.obx_date,'hh12:mi:ss pm') as obxtime, to_char(z.obx_date,'dd/mm/yyyy hh12:mi:ss pm') as obx_date, z.obx_measure, decode('");
	sbSql.append(mType);
	sbSql.append("','VS',(select description||decode(status,'I',' ***INACTIVE') from tbl_int_measure where code = z.obx_measure)) as obx_measure_desc, z.obx_measure_result, z.obx_measure_unit, z.obx_measure_ref, to_char(z.validated_date,'dd/mm/yyyy hh12:mi:ss pm') as validated_date, z.validated_by from tbl_int_measurement_validated z");
	sbSql.append(sbFilter);
	sbSql.append(" order by z.cds, z.room, z.bed, z.obx_date desc");
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sbSql+")");

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
document.title = 'Resultados de Mediciones - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - RESULTADO DE MEDICIONES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("mType",mType)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("admision",admision)%>
			<td>
				<cellbytelabel>Fecha</cellbytelabel>.
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2" />
				<jsp:param name="nameOfTBox1" value="fDate" />
				<jsp:param name="valueOfTBox1" value="<%=fDate%>" />
				<jsp:param name="nameOfTBox2" value="tDate" />
				<jsp:param name="valueOfTBox2" value="<%=tDate%>" />
				</jsp:include>
				<!--<cellbytelabel>Centro</cellbytelabel>
				<%//=fb.textBox("cds",cds,false,false,false,5)%>
				<cellbytelabel>Habitaci&oacuten</cellbytelabel>
				<%//=fb.textBox("room",room,false,false,false,10)%>
				<cellbytelabel>Cama</cellbytelabel>
				<%//=fb.textBox("bed",bed,false,false,false,10)%>-->
				<%=fb.submit("go","Ir")%>
			</td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
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
<%=fb.hidden("mType",mType)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("room",room)%>
<%=fb.hidden("bed",bed)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
<%=fb.hidden("mType",mType)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("room",room)%>
<%=fb.hidden("bed",bed)%>
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

<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart()%>
<%=fb.hidden("mType",mType)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("room",room)%>
<%=fb.hidden("bed",bed)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader">
			<td width="7%"><cellbytelabel>Fecha</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Hora</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Fecha/Hora Validaci&oacute;n</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Validado Por</cellbytelabel></td>
			<td width="15%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="16%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="16%"><cellbytelabel>Resultado</cellbytelabel></td>
			<td width="7%"><cellbytelabel>Unidad</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Valor Referencia</cellbytelabel></td>
			<td width="5%">&nbsp;</td>
		</tr>
<%
String groupBy = "";
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	if (!groupBy.equals(cdo.getColValue("cds")+"-"+cdo.getColValue("room")+"-"+cdo.getColValue("bed"))) {
%>
		<tr class="TextFilter">
			<td colspan="9">UBICACION: <%=cdo.getColValue("cds")%>-<%=cdo.getColValue("room")%>-<%=cdo.getColValue("bed")%> | PACIENTE: <%=cdo.getColValue("paciente")%></td>
			<td align="center">&nbsp;</td>
		</tr>
<%
	}
%>
<%=fb.hidden("mTime"+i,cdo.getColValue("obxtime"))%>
<%=fb.hidden("pacId"+i,cdo.getColValue("pac_id"))%>
<%=fb.hidden("admision"+i,cdo.getColValue("admision"))%>
<%=fb.hidden("cds"+i,cdo.getColValue("cds"))%>
<%=fb.hidden("room"+i,cdo.getColValue("room"))%>
<%=fb.hidden("bed"+i,cdo.getColValue("bed"))%>
<%=fb.hidden("mDate"+i,cdo.getColValue("obxdate"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("obxdate")%></td>
			<td align="center"><%=cdo.getColValue("obxtime")%></td>
			<td align="center"><%=cdo.getColValue("validated_date")%></td>
			<td align="center"><%=cdo.getColValue("validated_by")%></td>
			<td><%=cdo.getColValue("obx_measure")%></td>
			<td><%=cdo.getColValue("obx_measure_desc")%></td>
			<td><%=cdo.getColValue("obx_measure_result")%></td>
			<td><%=cdo.getColValue("obx_measure_unit")%></td>
			<td><%=cdo.getColValue("obx_measure_ref")%></td>
			<td align="center">&nbsp;</td>
		</tr>
<%
	groupBy = cdo.getColValue("cds")+"-"+cdo.getColValue("room")+"-"+cdo.getColValue("bed");
}
%>
		</table>
<%=fb.formEnd()%>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
</div>
</div>

	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
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
<%=fb.hidden("mType",mType)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("room",room)%>
<%=fb.hidden("bed",bed)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
<%=fb.hidden("mType",mType)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("room",room)%>
<%=fb.hidden("bed",bed)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<% } %>