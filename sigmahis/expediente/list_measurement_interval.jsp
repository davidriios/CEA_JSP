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
String validated  = request.getParameter("validated");
String fDate = request.getParameter("fDate");
String cds = request.getParameter("cds");
String room = request.getParameter("room");
String bed = request.getParameter("bed");
String pacBrazalete = request.getParameter("pacBrazalete");
String pacId = request.getParameter("pacId");
String admision = request.getParameter("admision");
String interval = request.getParameter("interval");
if (mType == null) mType = "VS";
if (validated == null) validated = "N";
if (fDate == null || fDate.trim().equals("")) fDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
if (cds == null) cds = "";
if (room == null) room = "";
if (bed == null) bed = "";
if (pacBrazalete == null) pacBrazalete = "";
if (pacId == null) pacId = "";
if (admision == null) admision = "";
if (interval == null) interval = "15";
if (pacBrazalete.trim().equals("")) { pacId = ""; admision = ""; }

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

	if (!cds.trim().equals("")) { sbFilter.append(" and a.cds = "); sbFilter.append(cds); }
	if (!room.trim().equals("")) { sbFilter.append(" and a.room = '"); sbFilter.append(room); sbFilter.append("'"); }
	if (!bed.trim().equals("")) { sbFilter.append(" and a.bed = '"); sbFilter.append(bed); sbFilter.append("'"); }
	if (!pacId.trim().equals("")) { sbFilter.append(" and a.pac_id = "); sbFilter.append(pacId); }
	if (!admision.trim().equals("")) { sbFilter.append(" and exists (select null from tbl_adm_admision z where pac_id = a.pac_id and secuencia = a.admision and adm_root = (select adm_root from tbl_adm_admision where pac_id = z.pac_id and secuencia = "); sbFilter.append(admision); sbFilter.append("))"); }
	//if (!validated.trim().equals("")) { sbFilter.append(" and b.validated = '"); sbFilter.append(validated); sbFilter.append("'"); }
	if (!fDate.trim().equals("")) {
		/*first interval including last previous day interval*/
		sbFilter.append(" and b.obx_date >= to_date('"); sbFilter.append(fDate); sbFilter.append("','dd/mm/yyyy') - (("); sbFilter.append(interval); sbFilter.append(" / 2) / (24 * 60))");
		/*last interval excluding rounding time to next day interval*/
		sbFilter.append(" and b.obx_date < to_date('"); sbFilter.append(fDate); sbFilter.append("','dd/mm/yyyy') + (1 - (("); sbFilter.append(interval); sbFilter.append(" / 2) / (24 * 60)))");
	}

	ArrayList alp = new ArrayList();
	if (!fDate.trim().equals("") && !pacId.trim().equals("") && !admision.trim().equals("")) {
		sbSql.append("select a.pac_id, a.admision, a.cds, a.room, a.bed from tbl_int_measurement a, tbl_int_measurement_det b where a.measurement_id = b.measurement_id");
		sbSql.append(sbFilter);
		sbSql.append(" and b.obx_measure != 'MODOVENT' and b.validated in ('N'/*,'P'*/) group by a.pac_id, a.admision, a.cds, a.room, a.bed");
		alp = SQLMgr.getDataList(sbSql.toString());
	}

	String pivotSql="select to_char(trunc(sysdate) + ((level-1)*"+interval+")/1440, 'HH24:MI') AS hhmm_interval from dual connect by level <= (1440/"+interval+")";
	String pivotList="";
	ArrayList alPivot = new ArrayList();
	alPivot=SQLMgr.getDataList(pivotSql);
	for(int ip=0;ip<alPivot.size();ip++){
		CommonDataObject cdo = (CommonDataObject) alPivot.get(ip);
		if(ip==0) pivotList="'"+cdo.getColValue("hhmm_interval")+"'";
		else pivotList=pivotList+",'"+cdo.getColValue("hhmm_interval")+"'";
	}

	sbSql = new StringBuffer();
	sbSql.append("select * from (");//query to get the closest positive diff to the given interval

		sbSql.append("select /*a.measurement_id, */a.pac_id, a.admision, nvl((select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id),'- SIN CUENTA -') as paciente, a.cds, a.room, a.bed/*, b.obx_date*/, b.obx_measure");
		if (mType.equalsIgnoreCase("VS")) sbSql.append(", (select description||decode(status,'I',' ***INACTIVE') from tbl_int_measure where code = b.obx_measure) as obx_measure_desc, (select display_order from tbl_int_measure where code = b.obx_measure) as obx_measure_order");
		else sbSql.append(", ' ' as obx_measure_desc, null as obx_measure_order");
		sbSql.append(", nvl(replace(regexp_substr(b.obx_segment,'([^|]*)(\\||$)',1,6),'|',''),'-') as result, to_date('");
		sbSql.append(fDate);
		sbSql.append("','dd/mm/yyyy') as obxdate, getDateDifRound(b.obx_date,");
		sbSql.append(interval);
		sbSql.append(",'T') as obxtime/*, getDateDifRound(b.obx_date,");
		sbSql.append(interval);
		sbSql.append(",'D') as nearest_time_interval*/");
		sbSql.append(", row_number() over(partition by a.pac_id, a.admision, a.cds, a.room, a.bed, b.obx_measure, trunc(b.obx_date), getDateDifRound(b.obx_date,");
		sbSql.append(interval);
		sbSql.append(",'T') order by abs(getDateDifRound(b.obx_date,");
		sbSql.append(interval);
		sbSql.append(",'D'))/*--- min diff ---*/, getDateDifRound(b.obx_date,");
		sbSql.append(interval);
		sbSql.append(",'D') desc/*--- the closest positive min diff ---*/) as priority");
		sbSql.append(" from tbl_int_measurement a, tbl_int_measurement_det b");
		sbSql.append(" where a.measurement_id = b.measurement_id and a.measurement_type = '");
		sbSql.append(mType);
		sbSql.append("' and a.validated in ('N'/*,'P'*/) and b.validated in ('N') and b.obx_measure != 'MODOVENT' and exists (select null from tbl_int_measure where code = b.obx_measure and status = 'A')");
		sbSql.append(sbFilter);
		//sbSql.append(" order by a.pac_id, a.admision, b.obx_measure, b.obx_date");

	sbSql.append(") where priority = 1 order by pac_id, admision, obx_measure_order, obx_measure, obxdate, obxtime");

	if (request.getParameter("fDate") != null && (!cds.trim().equals("") || !room.trim().equals("") || !bed.trim().equals("") || (!pacId.trim().equals("") && !admision.trim().equals("")))) {
		StringBuffer sbSqlFinal = new StringBuffer();
		sbSqlFinal.append("select * from (");
		sbSqlFinal.append(sbSql);
		sbSqlFinal.append(") pivot ( max(result) for obxtime in ("+pivotList+") )");
		sbSqlFinal.append(" order by pac_id, admision, obx_measure_order, obx_measure");
		al = SQLMgr.getDataList(sbSqlFinal.toString());
		rowCount = 0;//CmnMgr.getCount("select count(*) from ("+sbSqlFinal+")");
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
document.title = 'Interfaz de Mediciones x Interval- '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();<% if (alp.size() == 1) { CommonDataObject p = (CommonDataObject) alp.get(0); %>setPatient(<%=p.getColValue("pac_id")%>,<%=p.getColValue("admision")%>,<%=p.getColValue("cds")%>,'<%=p.getColValue("room")%>','<%=p.getColValue("bed")%>');<% } %>}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function getPB(){
	var pb = $("#pacBrazalete").val(), _pb = "";
	if (pb.indexOf("-") > 0){
	try{
		_pb = pb.split("-");
		_pb = _pb[0].lpad(10,"0")+""+_pb[1].lpad(3,"0");
	}catch(e){debug("ERROR getPB CAUSED BY: "+e.message);_pb="";}
	}else if (pb.trim().length == 13) _pb = pb;
	return _pb;
}
function doProcess(pb){
	var fDate = $("#fDate").val();
	if(fDate.trim()==''){alert('Por favor indicar la fecha!!');return;}
	var cds = $("#cds").val();
	var room = $("#room").val();
	var bed = $("#bed").val();
	var interval = $("#interval").val();
	var pacId = admision = "";
	var _pb = getPB(pb);
	if(_pb != ""){
		$("#pacBrazalete").val(_pb);
		pacId = parseInt(_pb.substr(0,10),10);
		admision = parseInt(_pb.substr(10),10);alert(_pb+' '+pacId+' '+admision);
		window.location.href = "..<%=request.getServletPath()%>?fDate="+fDate+"&cds="+cds+"&room="+room+"&bed="+bed+"&pacBrazalete="+_pb+"&pacId="+pacId+"&admision="+admision+"&interval="+interval;
	}else{CBMSG.error("Por favor escanee un brazalete o ingrese el ID del paciente en este formato: pacId-Adm");}
}
$(document).ready(function(){
	$("#pacBrazalete").click(function(){$(this).select();});
	$("#pacBrazalete").keyup(function(e){
		var pacBrazalete = "";
		var key;
		(window.event) ? key = window.event.keyCode : key = e.which;
		
		if(key == 13){
			pacBrazalete = $(this).val();
			if(pacBrazalete != ""){
				try{
					doProcess(pacBrazalete);  
				}catch(e){debug("Error caused by: "+e.message)}
			}
		}
	});
});
function setPatient(pacId,admision,cds,room,bed){
if(pacId==-999&&admision==-999)alert('No hay Cuenta designada para los Resultados de Mediciones! Por favor indicar la Cuenta para proceder a confirmar.');
document.form0.pacIdSrc.value=pacId;
document.form0.admisionSrc.value=admision;
document.form0.pacIdDest.value=(pacId==-999)?'':pacId;
document.form0.admisionDest.value=(admision==-999)?'':admision;
document.form0.pacIdDest.readOnly=(pacId!=-999);
document.form0.admisionDest.readOnly=(admision!=-999);
document.form0.cds.value=cds;
document.form0.room.value=room;
document.form0.bed.value=bed;
document.getElementById("location").innerHTML=" [ "+cds+"-"+room+"-"+bed+" ]";
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
	<jsp:param name="title" value="EXPEDIENTE - INTERFAZ MEDICIONES"></jsp:param>
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
<%fb.appendJsValidation("if(document.search00.fDate.value.trim()==''){error++;alert('Por favor indicar la fecha!');}");%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("mType",mType)%>
<%=fb.hidden("validated",validated)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("admision",admision)%>
			<td>
				<!--<cellbytelabel>Validado</cellbytelabel>-->
				<%//=fb.select("validated","Y=SI,N=NO",validated,false,false,0,null,null,null,null,"T")%>
				<cellbytelabel>Fecha</cellbytelabel>.
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="fDate" />
				<jsp:param name="valueOfTBox1" value="<%=fDate%>" />
				</jsp:include>
				<cellbytelabel>Interval</cellbytelabel>:
				<%=fb.select("interval","5=5 min,10=10 min,15=15 min,30=30 min,60=1 hora,120=2 horas,180=3 horas,240=4 horas",interval,false,false,0,null,null,null,null,"S")%></br>
				<cellbytelabel>Centro</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select codigo, codigo||' - '||descripcion from tbl_cds_centro_servicio where compania_unorg = "+session.getAttribute("_companyId")+" and estado = 'A' and si_no = 'S' order by 2","cds",cds,false,false,false,0,"S")%>
				<cellbytelabel>Habitaci&oacuten</cellbytelabel>
				<%=fb.textBox("room",room,false,false,false,10)%>
				<cellbytelabel>Cama</cellbytelabel>
				<%=fb.textBox("bed",bed,false,false,false,10)%>
				<cellbytelabel>Por favor Escanee un brazalete</cellbytelabel>:
				<%=fb.textBox("pacBrazalete",pacBrazalete,false,false,false,15,13,null,null,null,null,false,"tabindex=-1")%>
				<%=fb.submit("go","Desplegar")%>
			</td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
</tr>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mType",mType)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("room",room)%>
<%=fb.hidden("bed",bed)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("interval",interval)%>
<%=fb.hidden("pacIdSrc",pacId)%>
<%=fb.hidden("admisionSrc",admision)%>
<%=fb.hidden("size",""+alPivot.size())%>
<%fb.appendJsValidation("if(document.form0.cds.value.trim()==''||document.form0.room.value.trim()==''||document.form0.bed.value.trim()==''||document.form0.fDate.value.trim()==''||document.form0.interval.value.trim()==''){alert('Para confirmar se requiere lo siguiente:\\n*Fecha\\n*Intervalo\\n*Centro\\n*Habitación\\n*Cama');error++;}");%>
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
for (int ip=0; ip<alPivot.size(); ip++) {
	CommonDataObject cdo = (CommonDataObject) alPivot.get(ip);
%>
	<th><label><%=fb.checkbox("chk"+ip,cdo.getColValue("hhmm_interval"))%><%=cdo.getColValue("hhmm_interval")%></label></th>
<% } %>
</tr>
</thead>
<% if (al.size() > 0) { %><tbody><% } %>
<%
String groupBy = "";
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	if (!groupBy.equals(cdo.getColValue("cds")+"-"+cdo.getColValue("room")+"-"+cdo.getColValue("bed")+"-"+cdo.getColValue("pac_id")+"-"+cdo.getColValue("admision"))) {
%>
<tr class="TextRow02" onClick="javascript:setPatient(<%=cdo.getColValue("pac_id")%>,<%=cdo.getColValue("admision")%>,<%=cdo.getColValue("cds")%>,'<%=cdo.getColValue("room")%>','<%=cdo.getColValue("bed")%>');">
	<td class="zui-sticky-col group">[ <%=cdo.getColValue("cds")%>-<%=cdo.getColValue("room")%>-<%=cdo.getColValue("bed")%> ] &nbsp; &nbsp; &nbsp; ( <%=cdo.getColValue("pac_id")%>-<%=cdo.getColValue("admision")%> ) &nbsp; <%=cdo.getColValue("paciente")%></td>
<% for (int ip=0; ip<alPivot.size(); ip++) { %><td class="group">&nbsp;<!--=====--></td><% } %>
</tr>
<% } %>
<tr class="TextRow01">
	<td class="zui-sticky-col hint hint--right" data-hint="<%=cdo.getColValue("obx_measure")%>"><%=cdo.getColValue("obx_measure_desc")%></td><!--obx3-->
<%
for (int ip=0; ip<alPivot.size(); ip++) {
	CommonDataObject cdoPivot = (CommonDataObject) alPivot.get(ip);
%>
	<td><%=cdo.getColValue("'"+cdoPivot.getColValue("hhmm_interval")+"'","&nbsp;")%></td>
<% } %>
</tr>
<%
	groupBy = cdo.getColValue("cds")+"-"+cdo.getColValue("room")+"-"+cdo.getColValue("bed")+"-"+cdo.getColValue("pac_id")+"-"+cdo.getColValue("admision");
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
<tr class="TextRow01" align="center">
	<td colspan="2">Cuenta <%=fb.intBox("pacIdDest",(pacId.equals("-999"))?"":pacId,true,false,(!pacId.equals("-999")),10,null,null,null)%>-<%=fb.intBox("admisionDest",(admision.equals("-999"))?"":admision,true,false,(!admision.equals("-999")),3,null,null,null)%><label id="location"></label></td>
</tr>
<tr class="TextHeader01" align="center">
	<td colspan="2">
		<%=fb.submit("save","Confirmar",true,false,null,"","")%>
		<%=fb.button("cancel","Cancelar",false,false,null,"","onClick=\"javascript:window.close();\"")%>
	</td>
</tr>
<%=fb.formEnd(true)%>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
} else {
	int size = Integer.parseInt(request.getParameter("size"));
	StringBuffer sbCols = new StringBuffer();
	for (int i=0; i<size; i++) {
		if (request.getParameter("chk"+i) != null) {
			if (sbCols.length() > 0) sbCols.append(",");
			sbCols.append(request.getParameter("chk"+i));
		}
	}
System.out.println("------------------------->"+sbCols);
	CommonDataObject param = new CommonDataObject();//parametros para el procedimiento
	sbSql = new StringBuffer();
	sbSql.append("{ call sp_int_measurement_interval(?,?,?,?,?,?,?,?,?,?,?,?) }");
	param.setSql(sbSql.toString());
	param.addInStringStmtParam(1,mType);
	param.addInNumberStmtParam(2,cds);
	param.addInStringStmtParam(3,room);
	param.addInStringStmtParam(4,bed);
	param.addInStringStmtParam(5,fDate);
	param.addInNumberStmtParam(6,interval);
	param.addInNumberStmtParam(7,request.getParameter("pacIdSrc"));
	param.addInNumberStmtParam(8,request.getParameter("admisionSrc"));
	param.addInStringStmtParam(9,IBIZEscapeChars.forSingleQuots(((String) session.getAttribute("_userName")).trim()));
	param.addInNumberStmtParam(10,request.getParameter("pacIdDest"));
	param.addInNumberStmtParam(11,request.getParameter("admisionDest"));
	param.addInStringStmtParam(12,sbCols.toString());

	ConMgr.setClientIdentifier(((String) session.getAttribute("_userName")).trim()+":"+request.getRemoteAddr(),true);
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"cds="+cds+"&room="+room+"&bed="+bed+"&fDate="+fDate+"&interval="+interval+"&pacIdSrc="+request.getParameter("pacIdSrc")+"&admisionSrc="+request.getParameter("admisionSrc")+"&pacIdDest="+request.getParameter("pacIdDest")+"&admisionDest="+request.getParameter("admisionDest")+"&cols="+sbCols);
	param = SQLMgr.executeCallable(param);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<% if (SQLMgr.getErrCode().equals("1")) { %>
alert('<%=SQLMgr.getErrMsg()%>');
<% } else throw new Exception(SQLMgr.getErrException()); %>
window.opener.location.reload(true);
window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>