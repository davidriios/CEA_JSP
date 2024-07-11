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
StringBuffer sbSql = new StringBuffer();
String mId = request.getParameter("mId");
String cds = request.getParameter("cds");
String room = request.getParameter("room");
String bed = request.getParameter("bed");
String mDate = request.getParameter("mDate");//whole day formatted as dd/mm/yyyy
String pacId = "0";
String admision = "0";
if (!((mId != null && !mId.trim().equals("")) || (cds != null && !cds.trim().equals("") && room != null && !room.trim().equals("") && bed != null && !bed.trim().equals("") && mDate != null && !mDate.trim().equals("")))) throw new Exception("La Medición no es válida. Por favor intente nuevamente o consulte con su Administrador!");

if (mId != null && !mId.trim().equals("")) {
	sbSql.append("select z.pac_id, z.admision, z.cds, z.room, z.bed, to_char(z.message_date,'dd/mm/yyyy hh12:mi:ss am') as obr_date, (select nombre_paciente from vw_adm_paciente where pac_id = z.pac_id) as paciente from tbl_int_measurement z where z.measurement_id = ");
	sbSql.append(mId);
	CommonDataObject m = SQLMgr.getData(sbSql.toString());
	cds = m.getColValue("cds");
	room = m.getColValue("room");
	bed = m.getColValue("bed");
	mDate = m.getColValue("obr_date");//specific date/time formated as dd/mm/yyyy hh12:mi:ss am
	pacId = m.getColValue("pac_id");
	admision = m.getColValue("admision");
}

sbSql = new StringBuffer();
sbSql.append("select z.pac_id, z.admision, z.compania, z.habitacion, z.cama, to_char(min(trunc(z.fecha_inicio) + (z.hora_inicio - trunc(z.hora_inicio))),'dd/mm/yyyy hh12:mi:ss am') as fecha_hora_inicio, to_char(max(case when z.fecha_final is null then sysdate when z.fecha_final = trunc(z.fecha_final) then fecha_final + nvl(fecha_modificacion - trunc(fecha_modificacion),hora_inicio - trunc(hora_inicio)) else z.fecha_final end),'dd/mm/yyyy hh12:mi:ss am') as fecha_hora_final, (select nombre_paciente from vw_adm_paciente where pac_id = z.pac_id) as paciente, (select id_paciente from vw_adm_paciente where pac_id = z.pac_id) as identificacion, (select to_char(f_nac,'dd/mm/yyyy') from vw_adm_paciente where pac_id = z.pac_id) as dob, (select sexo from vw_adm_paciente where pac_id = z.pac_id) as sexo, (select (select nvl(nombre_corto,descripcion) from tbl_adm_categoria_admision where codigo = a.categoria) from tbl_adm_admision a where pac_id = z.pac_id and secuencia = z.admision) as categoria from tbl_adm_cama_admision z where z.habitacion = '");
sbSql.append(room);
sbSql.append("' and z.cama = '");
sbSql.append(bed);
sbSql.append("' and exists (select null from tbl_sal_habitacion where unidad_admin = ");
sbSql.append(cds);
sbSql.append(" and compania = z.compania and codigo = z.habitacion)");
if (mId != null && !mId.trim().equals("")) {
	sbSql.append(" and to_date('");
	sbSql.append(mDate);
	sbSql.append("','dd/mm/yyyy hh12:mi:ss am') between trunc(fecha_inicio) + (hora_inicio - trunc(hora_inicio)) and case when fecha_final is null then sysdate when fecha_final = trunc(fecha_final) then fecha_final + nvl(fecha_modificacion - trunc(fecha_modificacion),hora_inicio - trunc(hora_inicio)) else fecha_final end");//se toma la hora de fecha_modificacion u hora_inicio, ya que la hora_final es varchar2 y no tiene un patron concreto para definir el formato
	if (!pacId.equals("0")) { sbSql.append(" and z.pac_id = "); sbSql.append(pacId); }
	if (!admision.equals("0")) { sbSql.append(" and z.admision = "); sbSql.append(admision); }
} else {
	sbSql.append(" and to_date('");
	sbSql.append(mDate);
	sbSql.append("','dd/mm/yyyy') between trunc(fecha_inicio) and case when fecha_final is null then trunc(sysdate) else trunc(fecha_final) end");
}
sbSql.append(" group by z.pac_id, z.admision, z.compania, z.habitacion, z.cama");
al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET")) {
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Interfaz de Mediciones - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){<% if (al.size() > 0) { %>resetFrameHeight(document.getElementById('_cMain'),xHeight,200);<% } %>}
function setIdx(idx){document.form0.pacId.value=eval('document.form0.pacId'+idx).value;document.form0.admision.value=eval('document.form0.admision'+idx).value;}
function doSubmit(form,baction){
	setBAction(form.name,this.value);
<% if (mId != null && !mId.trim().equals("")) { %>
	form.submit();
<% } else { %>
	eval('parent.document.'+form.name+'.pacId').value=form.pacId.value;
	eval('parent.document.'+form.name+'.admision').value=form.admision.value;
	if(form.pacId.value!=''&&form.admision.value!=''&&window.parent.$("input[name^='chk<%=cds%>-<%=room%>-<%=bed%>-<%=mDate%>'][type='checkbox']:checked").length>0){
		parent.document.form0.submit();
	}
<% } %>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CONFIRMAR MEDICION"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="5" cellspacing="1" id="_tblMain">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mId",mId)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("room",room)%>
<%=fb.hidden("bed",bed)%>
<%=fb.hidden("mDate",mDate)%>
		<tr class="TextPanel" align="center">
			<td colspan="2"><cellbytelabel>Confirmar la cuenta del Paciente (<%=al.size()%>) para validar<% if (mId != null && !mId.trim().equals("")) { %> la Medición #<%=mId%><% } else { %> las Mediciones seleccionadas<% } %></td>
		</tr>
		<tr class="TextRow01">
			<td width="20%">Ubicaci&oacute;n</td>
			<td width="80%"><%=cds%>-<%=room%>-<%=bed%></td>
		</tr>
		<tr class="TextRow01">
			<td width="20%">Fecha<% if (mId != null && !mId.trim().equals("")) { %>/Hora<% } %></td>
			<td width="80%"><%=mDate%></td>
		</tr>
<% if (al.size() == 0 ) { %>
		<tr class="TextRow01" align="center">
			<td colspan="2">Cuenta <%=fb.intBox("pacId",(pacId.equals("-999"))?"":pacId,true,false,false,10,null,null,null)%>-<%=fb.intBox("admision",(admision.equals("-999"))?"":admision,true,false,false,3,null,null,null)%></td>
		</tr>
<% } else { %>
<%=fb.textBox("pacId",pacId)%>
<%=fb.textBox("admision",admision)%>
		<tr>
			<td colspan="2">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
				<table align="center" width="100%" cellpadding="1" cellspacing="1">
					<tr class="TextPanel" align="center">
						<td width="10%">PAC ID</td>
						<td width="30%">PACIENTE</td>
						<td width="5%">ADM.</td>
						<td width="5%">CAT.</td>
						<td width="12%">IDENTIFICACION</td>
						<td width="10%">F.NAC.</td>
						<td width="5%">SEXO</td>
						<td width="10%">INICIO</td>
						<td width="10%">FIN</td>
						<td width="3%">&nbsp;</td>
					</tr>
<%
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
<%=fb.hidden("pacId"+i,cdo.getColValue("pac_id"))%>
<%=fb.hidden("admision"+i,cdo.getColValue("admision"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" align="center">
			<td><%=cdo.getColValue("pac_id")%></td>
			<td align="left"><%=cdo.getColValue("paciente")%></td>
			<td><%=cdo.getColValue("admision")%></td>
			<td><%=cdo.getColValue("categoria")%></td>
			<td><%=cdo.getColValue("identificacion")%></td>
			<td><%=cdo.getColValue("dob")%></td>
			<td><%=cdo.getColValue("sexo")%></td>
			<td><%=cdo.getColValue("fecha_hora_inicio")%></td>
			<td><%=cdo.getColValue("fecha_hora_final")%></td>
			<td><%=fb.radio("chk","x",(pacId.equals(cdo.getColValue("pac_id")) && admision.equals(cdo.getColValue("admision"))),false,false,null,null,"onClick=\"javascript:setIdx("+i+")\"")%></td>
		</tr>
<% } %>
				</table>
</div>
</div>
			</td>
		</tr>
<% } %>
		<tr class="TextHeader01" align="center">
			<td colspan="2">
				<%=fb.button("save","Confirmar",true,false,null,"","onClick=\"javascript:doSubmit(this.form,this.value)\"")%>
				<%=fb.button("cancel","Cancelar",false,false,null,"","onClick=\"javascript:parent.hidePopWin(false)\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
} else {

	CommonDataObject param = new CommonDataObject();//parametros para el procedimiento
	String rParam = null;//parámetro que devuelve el procedimiento almacenado

	sbSql = new StringBuffer();
	sbSql.append("{ call sp_int_validate_measurement(?,?,?,?) }");
	param.setSql(sbSql.toString());
	param.addInNumberStmtParam(1,mId);
	param.addInNumberStmtParam(2,request.getParameter("pacId"));
	param.addInNumberStmtParam(3,request.getParameter("admision"));
	param.addInStringStmtParam(4,IBIZEscapeChars.forSingleQuots(((String) session.getAttribute("_userName")).trim()));

	ConMgr.setClientIdentifier(((String) session.getAttribute("_userName")).trim()+":"+request.getRemoteAddr(),true);
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mId="+mId+"&pacId="+request.getParameter("pacId")+"&admision="+request.getParameter("admision"));
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
parent.window.location.reload(true);
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>