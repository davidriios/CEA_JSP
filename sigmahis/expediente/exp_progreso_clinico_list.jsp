<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="java.util.Hashtable" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
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

boolean viewMode = false;
StringBuffer sbSql = new StringBuffer();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");
String code = request.getParameter("code");
String estado = request.getParameter("estado");
if (desc == null) desc = "";
if (code == null) code = "0";
if (estado == null) estado = "";
String expVersion = "1";
try { expVersion = java.util.ResourceBundle.getBundle("issi").getString("expediente.version"); } catch (Exception e) { }

if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	//PROGRESO CLINICO
	sbSql.append("select 'P' as type, a.progreso_id as id, a.fecha as sort_by, to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.fecha,'hh12:mi am') as hora, a.medico, ' ' as especialidad, a.observacion");
	sbSql.append(", (select nvl(reg_medico,codigo) from tbl_adm_medico where codigo = a.medico) as reg_medico");
	sbSql.append(", (select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo = a.medico) as nombre_medico");
	sbSql.append(", ' ' as especialidad_desc, decode(a.status,'A', 'ACTIVO', 'I', 'INVALIDA') as status_dsp from tbl_sal_progreso_clinico a where a.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and a.admision = ");
	sbSql.append(noAdmision);
	sbSql.append(" and a.status = 'A'");
	//INTERCONSULTA
	sbSql.append(" union all select 'I' as type, a.codigo as id, to_date(to_char(a.fecha,'dd/mm/yyyy') || to_char(a.hora,'hh12:mi am'),'dd/mm/yyyyhh12:mi am') as sort_by, to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.hora,'hh12:mi am') as hora, a.medico, nvl(a.cod_especialidad,' ') as especialidad, (select join(cursor(select rownum||'. '||nvl(observacion,' ') from tbl_sal_diagnostico_inter_esp where pac_id = a.pac_id and secuencia = a.secuencia and cod_interconsulta = a.codigo order by codigo),chr(13)) from dual) as observacion");
	sbSql.append(", (select nvl(reg_medico,codigo) from tbl_adm_medico where codigo = a.medico) as reg_medico");
	sbSql.append(", (select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo = a.medico) as nombre_medico");
	sbSql.append(", (select descripcion from tbl_adm_especialidad_medica where codigo = a.cod_especialidad) as especialidad_desc, '' as status_dsp");
	sbSql.append(" from tbl_sal_interconsultor_espec a where a.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and a.secuencia = ");
	sbSql.append(noAdmision);
	sbSql.append(" and exists (select null from tbl_sal_diagnostico_inter_esp where pac_id = a.pac_id and secuencia = a.secuencia)");
	sbSql.append(" order by sort_by desc, id desc");
	al = SQLMgr.getDataList(sbSql.toString());
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Progreso Clínico - '+document.title;

function doAction(){}
function printExp(option,id,type){
	if(type!=null&&type!=undefined&&type=='I'){
		abrir_ventana('../expediente/print_exp_seccion_50.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&IC_ID='+id);
	}else{
<% if (expVersion.equalsIgnoreCase("3")) { %>
	<%//detallado%>if(option==0) abrir_ventana("../expediente3.0/print_progreso_clinico.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&code="+id);
	<%//resumido%>else abrir_ventana("../expediente/print_progreso_clinico.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&code=0");
<%}else{%>
	<%//resumido%>if(option==0) abrir_ventana("../expediente/print_progreso_clinico.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&code="+id);
	<%//resumido%>else abrir_ventana("../expediente/print_progreso_clinico.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&code=0");
<%}%>
	}
}

function inactivate(button, code) {
	<%if(!estado.equalsIgnoreCase("F")){%>
	button.disabled = true
	button.innerHTML = 'Inactivando...';
	
	$.ajax({
		url: '<%=request.getContextPath()+request.getServletPath()%>',
		method: 'POST',
		data: {
			code: code,
			pacId: '<%=pacId%>',
			noAdmision: '<%=noAdmision%>',
			seccion: '<%=seccion%>',
			desc: '<%=desc%>',
			estado: '<%=estado%>',
		}
	}).done(function(response) {
		window.location.reload(true);
	}).fail(function() {
		button.disabled = false
		button.innerHTML = 'Inactivar';
		alert('Error inactivando el Progreso Clínico!');
	});
	<%} else {%>//<%}%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PROGRESO"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table width="100%" cellpadding="0" cellspacing="0" class="TableBorderLightGray">

				<tr>
			<td>
				<jsp:include page="../common/paciente.jsp" flush="true">
					<jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
					<jsp:param name="fp" value="expediente"></jsp:param>
					<jsp:param name="mode" value="view"></jsp:param>
					<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
				</jsp:include>
			</td>
		</tr>
		</table>
		<table width="100%" cellpadding="1" cellspacing="1" class="TableBorderLightGray">
		<tr class="TextRow02">
			<td colspan="3" align="right"><button type="button2" class="btn btn-inverse btn-sm" onClick="javascript:printExp(1)"><i class="fa fa-print fa-lg"></i> Imprimir Todos</button></td>
		</tr>

<%
String fecha = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	if(!fecha.trim().equals(cdo.getColValue("fecha")+"-"+cdo.getColValue("medico")))
	{
%>
		<tr class="TextRow02">
			<td colspan="3">&nbsp;</td>
		</tr>
		<tr class="TextHeader">
			<td colspan="2"><cellbytelabel id="1"><% if (cdo.getColValue("type").equalsIgnoreCase("I")) { %>Interconsultor [ <%=cdo.getColValue("especialidad_desc")%> ] <%} else { %>M&eacute;dico<% } %></cellbytelabel>: <%=cdo.getColValue("nombre_medico")%></td>
			<td width="50%" align="right"><cellbytelabel id="2">Fecha</cellbytelabel>: <%=cdo.getColValue("fecha")%></td>
		</tr>
		<tr class="TextHeader01" align="center">
			<td width="10%"><cellbytelabel id="3">Hora</cellbytelabel></td>
			<td width="75%"><cellbytelabel id="4">Observaciones del M&eacute;dico</cellbytelabel></td>
			<td width="15%"></td>
		</tr>
<%
	}
%>
		<tr class="<%=color%>">
			<td align="center"><%=cdo.getColValue("hora")%></td>
			<td><%=cdo.getColValue("observacion")%></td>
			<td align="center">
			 <button type="button" class="CellbyteBtn" onClick="javascript:printExp(0,<%=cdo.getColValue("id")%>,'<%=cdo.getColValue("type")%>')"><i class="fa fa-print fa-lg"></i> Imprimir</button>
			 &nbsp;

				<authtype type="50">
				<%if(cdo.getColValue("type"," ").trim().equalsIgnoreCase("P")){%>					
					<%if(cdo.getColValue("status_dsp"," ").trim().equalsIgnoreCase("ACTIVO") ){%>					
						 <button type="button" name="inactivar" class="CellbyteBtn" onClick="javascript:inactivate(this,<%=cdo.getColValue("id")%>)" <%=estado.equalsIgnoreCase("F")?" disabled":""%>>
							Inactivar
						</button>
					<%}%>
				<%}%>
				</authtype>
			 
			 </td>
		</tr>
<%
	fecha = cdo.getColValue("fecha")+"-"+cdo.getColValue("medico");
}
%>
		</table>
	</td>
</tr>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<tr>
	<td colspan="4" align="right">
		<%//if (expVersion.equalsIgnoreCase("3")) {%>
		<button type="button" class="btn btn-inverse btn-sm" onClick="javascript:printExp(1)"><i class="fa fa-print fa-lg"></i> Imprimir Todos</button><%//}%>
		<%=fb.button("close","Cerrar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
	</td>
</tr>
<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
}//GET
else {
	CommonDataObject cdo = new CommonDataObject();
	cdo.setTableName("tbl_sal_progreso_clinico");
	cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and progreso_id = "+request.getParameter("code"));

	cdo.addColValue("status", "I");
	cdo.addColValue("fecha_modificacion", "sysdate");
	cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
	
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"Inactivando el progreso clinigo # "+request.getParameter("code"));
	SQLMgr.update(cdo);
	ConMgr.clearAppCtx(null);
}
%>