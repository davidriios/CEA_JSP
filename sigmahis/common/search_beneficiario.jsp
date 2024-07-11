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
============================================================================
===========================================================================
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
String fp = request.getParameter("fp");
String index = request.getParameter("index");
String flag_tipo = request.getParameter("flag_tipo");
String sub_tipo = request.getParameter("sub_tipo");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");

String codigo = request.getParameter("codigo");
String nombre = request.getParameter("nombre");
if (codigo == null) codigo = "";
if (nombre == null) nombre = "";
if (sub_tipo == null) sub_tipo = "";

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

	if (!codigo.trim().equals("")) { sbFilter.append(" and upper(a.codigo) like '%"); sbFilter.append(codigo.toUpperCase()); sbFilter.append("%'"); }
	if (!nombre.trim().equals("")) { sbFilter.append(" and upper(a.nombre) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }

	if(request.getParameter("codigo")!= null){
	sbSql.append("select a.codigo, a.nombre, a.otra_descripcion, a.ruc, a.dv, a.tipo_persona, a.tipo_persona_desc, a.codigo_pac, a.provincia, a.sigla, a.tomo, a.asiento, a.cedula, a.compania, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, (select descripcion from tbl_con_catalogo_gral where cta1 = a.cta1 and cta2 = a.cta2 and cta3 = a.cta3 and cta4 = a.cta4 and cta5 = a.cta5 and cta6 = a.cta6 and compania = a.compania) as ctaDesc from vw_cxp_beneficiarios a where tipo = '");
	sbSql.append(flag_tipo);
	sbSql.append("' and compania in (0, ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(")");
	sbSql.append(sbFilter);
	if(flag_tipo.equals("PM")){
		sbSql.append(" and sub_tipo = '");
		sbSql.append(sub_tipo);
		sbSql.append("'");
	}
	sbSql.append(" order by a.nombre");
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
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
document.title = 'Beneficiarios - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function setBeneficiario(k){
<% if (fp.equalsIgnoreCase("orden_pago")) { %>
	window.opener.document.orden_pago.num_id_beneficiario.value = eval('document.beneficiario.codigo'+k).value;
	window.opener.document.orden_pago.nom_beneficiario.value = eval('document.beneficiario.nombre'+k).value;
	window.opener.document.orden_pago.ruc.value = eval('document.beneficiario.ruc'+k).value;
	window.opener.document.orden_pago.dv.value = eval('document.beneficiario.dv'+k).value;
	window.opener.document.orden_pago.tipo_persona.value = eval('document.beneficiario.tipo_persona'+k).value;
	window.opener.document.orden_pago.cod_paciente.value = eval('document.beneficiario.codigo_pac'+k).value;
	window.opener.document.orden_pago.pac_provincia.value = eval('document.beneficiario.provincia'+k).value;
	window.opener.document.orden_pago.pac_sigla.value = eval('document.beneficiario.sigla'+k).value;
	window.opener.document.orden_pago.pac_tomo.value = eval('document.beneficiario.tomo'+k).value;
	window.opener.document.orden_pago.pac_asiento.value = eval('document.beneficiario.asiento'+k).value;
	window.opener.document.orden_pago.nuevo.value = "N";
	if(window.opener.document.orden_pago.cta1)window.opener.document.orden_pago.cta1.value=eval('document.beneficiario.cta1'+k).value;
	if(window.opener.document.orden_pago.cta2)window.opener.document.orden_pago.cta2.value=eval('document.beneficiario.cta2'+k).value;
	if(window.opener.document.orden_pago.cta3)window.opener.document.orden_pago.cta3.value=eval('document.beneficiario.cta3'+k).value;
	if(window.opener.document.orden_pago.cta4)window.opener.document.orden_pago.cta4.value=eval('document.beneficiario.cta4'+k).value;
	if(window.opener.document.orden_pago.cta5)window.opener.document.orden_pago.cta5.value=eval('document.beneficiario.cta5'+k).value;
	if(window.opener.document.orden_pago.cta6)window.opener.document.orden_pago.cta6.value=eval('document.beneficiario.cta6'+k).value;
	if(window.opener.document.orden_pago.ctaDesc)window.opener.document.orden_pago.ctaDesc.value=eval('document.beneficiario.ctaDesc'+k).value;
<% } else if (fp.equalsIgnoreCase("fact_prov")) { %>
	window.opener.document.fact_prov.cod_proveedor.value = eval('document.beneficiario.codigo'+k).value;
	window.opener.document.fact_prov.desc_proveedor.value = eval('document.beneficiario.nombre'+k).value;
	window.opener.checkFactura();
<% } %>
	window.close();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE BENEFICIARIOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("flag_tipo",flag_tipo)%>
<%=fb.hidden("sub_tipo",sub_tipo)%>
			<td width="50%">
				<cellbytelabel>C&oacute;digo</cellbytelabel>
				<%=fb.textBox("codigo","",false,false,false,20)%>
			</td>
			<td width="50%">
				<cellbytelabel>Nombre</cellbytelabel>
				<%=fb.textBox("nombre","",false,false,false,40)%>
				<%=fb.submit("go","Ir")%>
			</td>
<%=fb.formEnd()%>
		</tr>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("flag_tipo",flag_tipo)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("sub_tipo",sub_tipo)%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("flag_tipo",flag_tipo)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("sub_tipo",sub_tipo)%>
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
		<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="list">
		<tr class="TextHeader" align="center">
			<td><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td><cellbytelabel>Nombre</cellbytelabel></td>
			<td><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td><cellbytelabel>R.U.C.</cellbytelabel></td>
			<td><cellbytelabel>D.V.</cellbytelabel></td>
			<td><cellbytelabel>Tipo Persona</cellbytelabel></td>
			<td><cellbytelabel>Cod. Pac.</cellbytelabel></td>
			<td><cellbytelabel>C&eacute;dula</cellbytelabel></td>
		</tr>
<%fb = new FormBean("beneficiario",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
		<%=fb.hidden("ruc"+i,cdo.getColValue("ruc"))%>
		<%=fb.hidden("otra_descripcion"+i,cdo.getColValue("otra_descripcion"))%>
		<%=fb.hidden("dv"+i,cdo.getColValue("dv"))%>
		<%=fb.hidden("tipo_persona"+i,cdo.getColValue("tipo_persona"))%>
		<%=fb.hidden("codigo_pac"+i,cdo.getColValue("codigo_pac"))%>
		<%=fb.hidden("provincia"+i,cdo.getColValue("provincia"))%>
		<%=fb.hidden("sigla"+i,cdo.getColValue("sigla"))%>
		<%=fb.hidden("tomo"+i,cdo.getColValue("tomo"))%>
		<%=fb.hidden("asiento"+i,cdo.getColValue("asiento"))%>
		<%=fb.hidden("cta1"+i,cdo.getColValue("cta1"))%>
		<%=fb.hidden("cta2"+i,cdo.getColValue("cta2"))%>
		<%=fb.hidden("cta3"+i,cdo.getColValue("cta3"))%>
		<%=fb.hidden("cta4"+i,cdo.getColValue("cta4"))%>
		<%=fb.hidden("cta5"+i,cdo.getColValue("cta5"))%>
		<%=fb.hidden("cta6"+i,cdo.getColValue("cta6"))%>
		<%=fb.hidden("ctaDesc"+i,cdo.getColValue("ctaDesc"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setBeneficiario(<%=i%>)" style="cursor:pointer">
			<td><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("nombre")%></td>
			<td><%=cdo.getColValue("otra_descripcion")%></td>
			<td><%=cdo.getColValue("ruc")%></td>
			<td><%=cdo.getColValue("dv")%></td>
			<td><%=cdo.getColValue("tipo_persona_desc")%></td>
			<td align="center"><%=cdo.getColValue("codigo_pac")%></td>
			<td><%=cdo.getColValue("cedula")%></td>
		</tr>
<% } %>
<%=fb.formEnd()%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("flag_tipo",flag_tipo)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("sub_tipo",sub_tipo)%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("flag_tipo",flag_tipo)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("sub_tipo",sub_tipo)%>
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