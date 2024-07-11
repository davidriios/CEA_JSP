<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
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
CommonDataObject cdo = new CommonDataObject();
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String pacId = (request.getParameter("pacId")==null?"":request.getParameter("pacId"));
String noAdmision = (request.getParameter("noAdmision")==null?"":request.getParameter("noAdmision"));
String medico_empresa = (request.getParameter("medico_empresa")==null?"":request.getParameter("medico_empresa"));
String search = (request.getParameter("search")==null?"":request.getParameter("search"));
String cLang = (session.getAttribute("_locale")==null?"es":((java.util.Locale)session.getAttribute("_locale")).getLanguage());

String appendFilter = (!search.trim().equals("")?" and upper(nombre) like '%"+search+"%'":"");

if (pacId.trim().equals("")) throw new Exception("No pudimos encontrar el paciente!");
if (noAdmision.trim().equals("")) throw new Exception("No pudimos encontrar la admisión!");

StringBuffer sbSql = new StringBuffer();
sbSql.append("select x.no_documento, to_char(x.fecha, 'dd/mm/yyyy') fecha, decode(nvl (pagar_sociedad, 'N'), 'N', (select decode(e.sexo,'F','DRA. ','DR. ')||e.primer_nombre||decode(e.segundo_nombre,null,'',' '||e.segundo_nombre)||' '||e.primer_apellido||decode(e.segundo_apellido,null,'',' '||e.segundo_apellido)||decode(e.sexo,'F',decode(e.apellido_de_casada,null,'',' '||e.apellido_de_casada)) from tbl_adm_medico e where codigo =  med_codigo), 'S', (select nombre from tbl_adm_empresa where to_char(codigo) = empre_codigo)) medico_empresa, decode(nvl (pagar_sociedad, 'N'), 'N', med_codigo, 'S', empre_codigo) cod_med_empresa, pagar_sociedad, decode(nvl (pagar_sociedad, 'N'), 'N', (select nvl(reg_medico,codigo) from tbl_adm_medico e where codigo =  med_codigo), 'S', ' ') reg_medico from tbl_fac_transaccion x where tipo_transaccion = 'H' and x.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and x.admi_secuencia = ");
sbSql.append(noAdmision);
if(!medico_empresa.equals("")){
sbSql.append(" and decode(nvl (pagar_sociedad, 'N'), 'N', med_codigo, 'S', to_char(empre_codigo)) = '");
sbSql.append(medico_empresa);
sbSql.append("'");
}
sbSql.append(" and exists (select nvl(a.descripcion, ' ') as descripcion, monto, nvl(a.centro_costo, 0) as centro_costo, nvl(a.costo_art, 0) as costo_art, a.tipo_cargo as tipo_servicio, nvl(sum(case when a.tipo_transaccion in ('C', 'H') then a.cantidad else 0 end), 0) as cantidad_cargo, a.centro_servicio, a.honorario_por from tbl_fac_detalle_transaccion a where a.pac_id = x.pac_id and a.fac_secuencia = x.admi_secuencia and x.codigo = a.fac_codigo and x.tipo_transaccion = a.tipo_transaccion and x.compania = a.compania and x.centro_servicio = 0 group by nvl(a.descripcion, ' '), monto, nvl(a.centro_costo, 0), nvl(a.costo_art, 0), a.tipo_cargo, a.centro_servicio, a.honorario_por having nvl( sum(case when a.tipo_transaccion in ('C', 'H') then a.cantidad else -1 * a.cantidad end), 0 ) > 0)");
al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET")) {
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Common - Consentimiento - '+document.title;
function doAction(){newHeight();}
function addBoleta(k){
	window.opener.document.form0.noDocumento.value = eval('document.form0.noDocumento'+k).value;
	if(eval('document.form0.pagar_sociedad'+k).value=='S'){
		window.opener.document.form0.empreCodigo.value = eval('document.form0.codigo'+k).value;
		window.opener.document.form0.empreDesc.value = eval('document.form0.nombre'+k).value;
		window.opener.document.form0.pagar_sociedad.checked = true;
		window.opener.document.form0.medico.value = '';
		window.opener.document.form0.nombreMedico.value = '';
		window.opener.document.form0.reg_medico.value = '';
		
	}
	else {
		window.opener.document.form0.medico.value = eval('document.form0.codigo'+k).value;
		window.opener.document.form0.nombreMedico.value = eval('document.form0.nombre'+k).value;
		window.opener.document.form0.reg_medico.value = eval('document.form0.reg_medico'+k).value;
		window.opener.document.form0.empreCodigo.value = '';
		window.opener.document.form0.empreDesc.value = '';
		window.opener.document.form0.pagar_sociedad.checked = false;
	}
	window.close();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="Administración - Listado de Boletas"></jsp:param>
</jsp:include>
<table align="center" width="97%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="3" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("size",""+al.size())%>
		<tr class="TextRow02">
			<td align="right" colspan="3">
			<%=fb.button("btnCerrar","Cerrar",true,false,"Text10",null,"onClick=window.close();")%></td>
		</tr>
		<tr class="TextHeader">
			<td width="70%"><cellbytelabel>M&eacute;dico/Empresa</cellbytelabel></td>
			<td width="15%" align="center"><cellbytelabel>Boleta</cellbytelabel></td>
			<td width="15%" align="center"><cellbytelabel>Fecha</cellbytelabel></td>
		</tr>
<%
for (int c = 0; c<al.size(); c++){
	cdo = (CommonDataObject)al.get(c);
	String color = "TextRow02";
	if (c % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("noDocumento"+c,cdo.getColValue("no_documento"))%>
		<%=fb.hidden("codigo"+c,cdo.getColValue("cod_med_empresa"))%>
		<%=fb.hidden("nombre"+c,cdo.getColValue("medico_empresa"))%>
		<%=fb.hidden("pagar_sociedad"+c,cdo.getColValue("pagar_sociedad"))%>
		<%=fb.hidden("reg_medico"+c,cdo.getColValue("reg_medico"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:addBoleta('<%=c%>')" style="cursor:pointer">
			<td><%=cdo.getColValue("medico_empresa")%></td>
			<td><%=cdo.getColValue("no_documento")%></td>
			<td><%=cdo.getColValue("fecha")%></td>
		</tr>
<% } %>
<%=fb.formEnd()%>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
} else {
	session.setAttribute("_sel",request.getParameter("totSel"));
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
	window.open("../admision/print_unified_consent.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&pac_id=<%=pacId%>&no_adm=<%=noAdmision%>");
	document.location = "../common/sel_consentimiento.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&pac_id=<%=pacId%>&no_adm=<%=noAdmision%>";
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>