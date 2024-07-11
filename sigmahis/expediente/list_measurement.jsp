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
	String validated  = request.getParameter("validated");
	String fDate = request.getParameter("fDate");
	String tDate = request.getParameter("tDate");
	String cds = request.getParameter("cds");
	String room = request.getParameter("room");
	String bed = request.getParameter("bed");
	String pacBrazalete = request.getParameter("pacBrazalete");
	String pacId = request.getParameter("pacId");
	String admision = request.getParameter("admision");
	if (mType == null) mType = "VS";
	if (validated == null) validated = "N";
	if (fDate == null) fDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
	if (tDate == null) tDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
	if (cds == null) cds = "";
	if (room == null) room = "";
	if (bed == null) bed = "";
	if (pacBrazalete == null) pacBrazalete = "";
	if (pacId == null) pacId = "";
	if (admision == null) admision = "";

	if (!fDate.trim().equals("") && !pacId.trim().equals("") && !admision.trim().equals("")) {
		sbSql.append("select cds, room, bed from tbl_int_measurement a, tbl_int_measurement_det b where a.measurement_id = b.measurement_id and trunc(b.obx_date) = to_date('");
		sbSql.append(fDate);
		sbSql.append("','dd/mm/yyyy') and a.pac_id = ");
		sbSql.append(pacId);
		sbSql.append(" and a.admision = ");
		sbSql.append(admision);
		if (!cds.trim().equals("")) { sbSql.append(" and a.cds = "); sbSql.append(cds); }
		if (!room.trim().equals("")) { sbSql.append(" and a.room = '"); sbSql.append(room); sbSql.append("'"); }
		if (!bed.trim().equals("")) { sbSql.append(" and a.bed = '"); sbSql.append(bed); sbSql.append("'"); }
		sbSql.append(" and rownum = 1 and b.obx_measure != 'MODOVENT' and b.validated in ('N','P')");
		CommonDataObject cdoCDSBed = SQLMgr.getData(sbSql.toString());
		if (cdoCDSBed != null) {
			cds = cdoCDSBed.getColValue("cds");
			room = cdoCDSBed.getColValue("room");
			bed = cdoCDSBed.getColValue("bed");
		}
	}

	sbFilter.append(" where exists (select null from tbl_int_measurement y where measurement_id = z.measurement_id and validated in ('N','P') and measurement_type = '");
	sbFilter.append(mType);
	sbFilter.append("'");
	if (!cds.trim().equals("")) { sbFilter.append(" and cds = "); sbFilter.append(cds); }
	if (!room.trim().equals("")) { sbFilter.append(" and room = '"); sbFilter.append(room); sbFilter.append("'"); }
	if (!bed.trim().equals("")) { sbFilter.append(" and bed = '"); sbFilter.append(bed); sbFilter.append("'"); }
	if (!pacId.trim().equals("")) { sbFilter.append(" and pac_id = "); sbFilter.append(pacId); }
	if (!admision.trim().equals("")) { sbFilter.append(" and exists (select null from tbl_adm_admision a where pac_id = y.pac_id and secuencia = y.admision and adm_root = (select adm_root from tbl_adm_admision where pac_id = a.pac_id and secuencia = "); sbFilter.append(admision); sbFilter.append("))"); }
	sbFilter.append(")");
	if (!validated.trim().equals("")) { sbFilter.append(" and z.validated = '"); sbFilter.append(validated); sbFilter.append("'"); }
	if (!fDate.trim().equals("")) { sbFilter.append(" and trunc(z.obx_date) >= to_date('"); sbFilter.append(fDate); sbFilter.append("','dd/mm/yyyy')"); }
	if (!tDate.trim().equals("")) { sbFilter.append(" and trunc(z.obx_date) <= to_date('"); sbFilter.append(tDate); sbFilter.append("','dd/mm/yyyy')"); }

	sbSql = new StringBuffer();
	sbSql.append("select z.measurement_id, (select pac_id from tbl_int_measurement where measurement_id = z.measurement_id) as pac_id, (select admision from tbl_int_measurement where measurement_id = z.measurement_id) as admision, nvl((select (select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id) from tbl_int_measurement a where measurement_id = z.measurement_id),' ') as paciente, (select cds from tbl_int_measurement where measurement_id = z.measurement_id) as cds, (select room from tbl_int_measurement where measurement_id = z.measurement_id) as room, (select bed from tbl_int_measurement where measurement_id = z.measurement_id) as bed, (select to_char(message_date,'dd/mm/yyyy hh24:mi:ss') from tbl_int_measurement where measurement_id = z.measurement_id) as obr_date, (select validated from tbl_int_measurement where measurement_id = z.measurement_id) as validated, z.obx_rec_no, z.obx_measure");
	if (mType.equalsIgnoreCase("VS")) sbSql.append(", (select description||decode(status,'I',' ***INACTIVE') from tbl_int_measure where code = z.obx_measure) as obx_measure_desc");
	else sbSql.append(", ' ' as obx_measure_desc");
	sbSql.append(", to_char(z.obx_date,'dd/mm/yyyy') as obx_date, to_char(z.obx_date,'hh24:mi:ss') as obx_time, to_char(z.obx_date,'dd/mm/yyyy hh24:mi:ss') as obx_date_time, z.obx_segment from tbl_int_measurement_det z");
	sbSql.append(sbFilter);
	sbSql.append(" order by abs((select cds from tbl_int_measurement where measurement_id = z.measurement_id))/*5*/, 6/*room*/, 7/*bed*/, z.obx_date desc, z.measurement_id desc");
	if (mType.equalsIgnoreCase("VS")) sbSql.append(", (select display_order from tbl_int_measure where code = z.obx_measure)");
	sbSql.append(", z.obx_measure");
	if (request.getParameter("fDate") != null) {
		al = SQLMgr.getDataList("select zz.*, replace(regexp_substr(zz.obx_segment,'([^|]*)(\\||$)',1,1),'|','') as obx0, replace(regexp_substr(zz.obx_segment,'([^|]*)(\\||$)',1,2),'|','') as obx1, replace(regexp_substr(zz.obx_segment,'([^|]*)(\\||$)',1,3),'|','') as obx2, replace(regexp_substr(zz.obx_segment,'([^|]*)(\\||$)',1,4),'|','') as obx3, replace(regexp_substr(zz.obx_segment,'([^|]*)(\\||$)',1,5),'|','') as obx4, replace(regexp_substr(zz.obx_segment,'([^|]*)(\\||$)',1,6),'|','') as obx5, replace(regexp_substr(zz.obx_segment,'([^|]*)(\\||$)',1,7),'|','') as obx6, replace(regexp_substr(zz.obx_segment,'([^|]*)(\\||$)',1,8),'|','') as obx7, replace(regexp_substr(zz.obx_segment,'([^|]*)(\\||$)',1,9),'|','') as obx8, replace(regexp_substr(zz.obx_segment,'([^|]*)(\\||$)',1,10),'|','') as obx9, replace(regexp_substr(zz.obx_segment,'([^|]*)(\\||$)',1,11),'|','') as obx10, replace(regexp_substr(zz.obx_segment,'([^|]*)(\\||$)',1,12),'|','') as obx11, replace(regexp_substr(zz.obx_segment,'([^|]*)(\\||$)',1,13),'|','') as obx12, replace(regexp_substr(zz.obx_segment,'([^|]*)(\\||$)',1,14),'|','') as obx13, replace(regexp_substr(zz.obx_segment,'([^|]*)(\\||$)',1,15),'|','') as obx14 from (select rownum as rn, a.* from ("+sbSql+") a) zz where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from ("+sbSql+")");
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
document.title = 'Interfaz de Mediciones - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function validate(mId) {
	showPopWin('../process/int_validate_measurement.jsp?mId='+mId,winWidth*.75,winHeight*.65,null,null,'');
}
function validateBatch(cds,room,bed,mDate){
	showPopWin('../process/int_validate_measurement.jsp?cds='+cds+'&room='+room+'&bed='+bed+'&mDate='+mDate,winWidth*.75,winHeight*.65,null,null,'');
}
function chkMeasurement(chkObj,idx){
	if(chkObj.checked){
		//only first time
		if(document.form0.cds.value==''){
			document.form0.cds.value=eval('document.form0.cds'+idx).value;
			document.form0.room.value=eval('document.form0.room'+idx).value;
			document.form0.bed.value=eval('document.form0.bed'+idx).value;
			document.form0.mDate.value=eval('document.form0.mDate'+idx).value;
		}
		var cds=document.form0.cds.value;
		var room=document.form0.room.value;
		var bed=document.form0.bed.value;
		var mDate=document.form0.mDate.value;
		if(document.form0.cds.value!=eval('document.form0.cds'+idx).value||document.form0.room.value!=eval('document.form0.room'+idx).value||document.form0.bed.value!=eval('document.form0.bed'+idx).value||document.form0.mDate.value!=eval('document.form0.mDate'+idx).value){alert('Solo se permite seleccionar items del mismo grupo!');chkObj.checked=false;}
	}else{
		var cds=eval('document.form0.cds'+idx).value;
		var room=eval('document.form0.room'+idx).value;
		var bed=eval('document.form0.bed'+idx).value;
		var mDate=eval('document.form0.mDate'+idx).value;
		if ($("input[name^='chk"+cds+'-'+room+'-'+bed+'-'+mDate+"'][type='checkbox']:checked").length == 0) {
			document.form0.cds.value='';
			document.form0.room.value='';
			document.form0.bed.value='';
			document.form0.mDate.value='';
		}
	}
}
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
	var tDate = $("#tDate").val();
	var cds = $("#cds").val();
	var room = $("#room").val();
	var bed = $("#bed").val();
	var pacId = admision = "";
	var _pb = getPB(pb);
	if(_pb != ""){
		$("#pacBrazalete").val(_pb);
		pacId = parseInt(_pb.substr(0,10),10);
		admision = parseInt(_pb.substr(10),10);alert(_pb+' '+pacId+' '+admision);
		window.location.href = "../expediente/list_measurement.jsp?fDate="+fDate+"&tDate="+tDate+"&cds="+cds+"&room="+room+"&bed="+bed+"&pacBrazalete="+_pb+"&pacId="+pacId+"&admision="+admision;
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
function confirmarPorInterval(){
	var fDate = $("#fDate").val();
	var cds = $("#cds").val();
	var room = $("#room").val();
	var bed = $("#bed").val();
	var pacId = admision = "";
	var _pb = getPB();
	if(_pb != ""){
		pacId = parseInt(_pb.substr(0,10),10);
		admision = parseInt(_pb.substr(10),10);
	}
	//showPopWin("../expediente/list_measurement_interval.jsp?fDate="+fDate+"&cds="+cds+"&room="+room+"&bed="+bed,winWidth*.75,winHeight*.85,null,null,'');
	abrir_ventana("../expediente/list_measurement_interval.jsp?fDate="+fDate+"&cds="+cds+"&room="+room+"&bed="+bed+"&pacBrazalete="+_pb+"&pacId="+pacId+"&admision="+admision);
}	
</script>
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
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("mType",mType)%>
<%=fb.hidden("validated",validated)%>
			<td>
				<!--<cellbytelabel>Validado</cellbytelabel>-->
				<%//=fb.select("validated","Y=SI,N=NO",validated,false,false,0,null,null,null,null,"T")%>
				<cellbytelabel>Fecha</cellbytelabel>.
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2" />
				<jsp:param name="nameOfTBox1" value="fDate" />
				<jsp:param name="valueOfTBox1" value="<%=fDate%>" />
				<jsp:param name="nameOfTBox2" value="tDate" />
				<jsp:param name="valueOfTBox2" value="<%=tDate%>" />
				</jsp:include></br>
				<cellbytelabel>Centro</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select codigo, codigo||' - '||descripcion from tbl_cds_centro_servicio where compania_unorg = "+session.getAttribute("_companyId")+" and estado = 'A' and si_no = 'S' order by 2","cds",cds,false,false,false,0,"S")%>
				<cellbytelabel>Habitaci&oacuten</cellbytelabel>
				<%=fb.textBox("room",room,false,false,false,10)%>
				<cellbytelabel>Cama</cellbytelabel>
				<%=fb.textBox("bed",bed,false,false,false,10)%>
				<cellbytelabel>Por favor Escanee un brazalete</cellbytelabel>:
				<%=fb.textBox("pacBrazalete",pacBrazalete,false,false,false,15,13,null,null,null,null,false,"tabindex=-1")%>
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
		<td align="right">
			<authtype type='0'><a href="javascript:confirmarPorInterval()" class="Link00">[ <cellbytelabel>Confirmar X Interval</cellbytelabel> ]</a></authtype>
			&nbsp;
		</td>
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
<%=fb.hidden("validated",validated)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("room",room)%>
<%=fb.hidden("bed",bed)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("pacBrazalete",pacBrazalete)%>
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
<%=fb.hidden("validated",validated)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("room",room)%>
<%=fb.hidden("bed",bed)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("pacBrazalete",pacBrazalete)%>
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
<%=fb.hidden("validated",validated)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("cds","")%>
<%=fb.hidden("room","")%>
<%=fb.hidden("bed","")%>
<%=fb.hidden("mDate","")%>
<%=fb.hidden("pacId","")%>
<%=fb.hidden("admision","")%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader">
			<td width="15%"><cellbytelabel>C&oacute;digo</cellbytelabel></td><!--obx3-->
			<td width="25%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="30%"><cellbytelabel>Resultado</cellbytelabel></td><!--obx5-->
			<td width="10%"><cellbytelabel>Unidad</cellbytelabel></td><!--obx6-->
			<td width="15%"><cellbytelabel>Valor Referencia</cellbytelabel></td><!--obx7-->
			<td width="5%">&nbsp;</td>
		</tr>
<%
String groupBy = "", sGroupBy = "";
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	if (!groupBy.equals(cdo.getColValue("cds")+"-"+cdo.getColValue("room")+"-"+cdo.getColValue("bed")+"-"+cdo.getColValue("obx_date"))) {
%>
		<tr class="TextFilter">
			<td colspan="5">UBICACION: <%=cdo.getColValue("cds")%>-<%=cdo.getColValue("room")%>-<%=cdo.getColValue("bed")%> | FECHA: <%=cdo.getColValue("obx_date")%></td>
			<td align="center">&nbsp;<authtype type="3"><a href="javascript:validateBatch(<%=cdo.getColValue("cds")%>,'<%=cdo.getColValue("room")%>','<%=cdo.getColValue("bed")%>','<%=cdo.getColValue("obx_date")%>')"><img src="../images/multiple-choice.png" width="30" height="30"></a></authtype></td>
		</tr>
<%
		sGroupBy = "";
	}
	if (!sGroupBy.equals(cdo.getColValue("measurement_id"))) {
%>
<%=fb.hidden("mId"+i,cdo.getColValue("measurement_id"))%>
<%=fb.hidden("pacId"+i,cdo.getColValue("pac_id"))%>
<%=fb.hidden("admision"+i,cdo.getColValue("admision"))%>
<%=fb.hidden("cds"+i,cdo.getColValue("cds"))%>
<%=fb.hidden("room"+i,cdo.getColValue("room"))%>
<%=fb.hidden("bed"+i,cdo.getColValue("bed"))%>
<%=fb.hidden("mDate"+i,cdo.getColValue("obx_date"))%>
		<tr class="TextHeader01">
			<td colspan="5"><authtype type="3"><% if (!cdo.getColValue("validated").equalsIgnoreCase("Y")) { %><a href="javascript:validate(<%=cdo.getColValue("measurement_id")%>)"><img src="../images/checked.png" width="30" height="30"></a><% } %></authtype> HORA: <%=cdo.getColValue("obx_time")%> | BLOQUE #<%=cdo.getColValue("measurement_id")%><% if (!cdo.getColValue("paciente").trim().equals("")) { %> | PACIENTE: <%=cdo.getColValue("paciente")%><% } %></td>
			<td align="center">&nbsp;<% if (!cdo.getColValue("validated").equalsIgnoreCase("Y")) { %><%=fb.checkbox("chk"+cdo.getColValue("cds")+"-"+cdo.getColValue("room")+"-"+cdo.getColValue("bed")+"-"+cdo.getColValue("obx_date")+"-"+i,"x",false,false,null,null,"onClick=\"javascript:chkMeasurement(this,"+i+")\"",null)%><% } %></td>
		</tr>
<% } %>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("obx_measure")%></td>
			<td><%=cdo.getColValue("obx_measure_desc")%></td>
			<td><%=cdo.getColValue("obx5")%></td>
			<td><%=cdo.getColValue("obx6")%></td>
			<td><%=cdo.getColValue("obx7")%></td>
			<td align="center">&nbsp;</td>
		</tr>
<%
	sGroupBy = cdo.getColValue("measurement_id");
	groupBy = cdo.getColValue("cds")+"-"+cdo.getColValue("room")+"-"+cdo.getColValue("bed")+"-"+cdo.getColValue("obx_date");
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
<%=fb.hidden("validated",validated)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("room",room)%>
<%=fb.hidden("bed",bed)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("pacBrazalete",pacBrazalete)%>
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
<%=fb.hidden("validated",validated)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("room",room)%>
<%=fb.hidden("bed",bed)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("pacBrazalete",pacBrazalete)%>
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
<%
} else {

	String cds = request.getParameter("cds");
	String room = request.getParameter("room");
	String bed = request.getParameter("bed");
	String mDate = request.getParameter("mDate");
	int size = Integer.parseInt(request.getParameter("size"));
	Hashtable<String,CommonDataObject> htParams = new Hashtable<String,CommonDataObject>(); 
	for (int i=0; i<size; i++) {
		String mId = request.getParameter("mId"+i);
		if (request.getParameter("chk"+cds+"-"+room+"-"+bed+"-"+mDate+"-"+i) != null) {
			CommonDataObject param = new CommonDataObject();//parametros para el procedimiento
			sbSql = new StringBuffer();
			sbSql.append("{ call sp_int_validate_measurement(?,?,?,?) }");
			param.setSql(sbSql.toString());
			param.addInNumberStmtParam(1,mId);
			param.addInNumberStmtParam(2,request.getParameter("pacId"));
			param.addInNumberStmtParam(3,request.getParameter("admision"));
			param.addInStringStmtParam(4,IBIZEscapeChars.forSingleQuots(((String) session.getAttribute("_userName")).trim()));
				
			param.setKey(htParams.size());
			try { htParams.put(param.getKey(),param); } catch(Exception e) { System.out.println("Unable to add params!"); }
		}
	}

	ConMgr.setClientIdentifier(((String) session.getAttribute("_userName")).trim()+":"+request.getRemoteAddr(),true);
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"cds="+cds+"&room="+room+"&bed="+bed+"&mDate="+mDate+"&pacId="+request.getParameter("pacId")+"&admision="+request.getParameter("admision"));
	SQLMgr.executeCallableList(htParams);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<% if (SQLMgr.getErrCode().equals("1")) { %>
alert('<%=SQLMgr.getErrMsg()%>');
<% } else throw new Exception(SQLMgr.getErrException()); %>
window.location='<%=request.getContextPath()+request.getServletPath()%>?fDate=<%=request.getParameter("fDate")%>&tDate=<%=request.getParameter("tDate")%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>