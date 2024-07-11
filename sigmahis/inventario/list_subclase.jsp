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
<jsp:useBean id="vClases" scope="session" class="java.util.Vector" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String codigo = request.getParameter("codigo");
String descripcion = request.getParameter("descripcion");
String familia = request.getParameter("familia");
String clase = request.getParameter("clase");
String clase_desc = request.getParameter("clase_desc");
String fg = request.getParameter("fg");
String compRef = request.getParameter("compRef");
String index = request.getParameter("index");

if(codigo==null) codigo = "";
if(descripcion==null) descripcion = "";
if(familia==null) familia = "";
if(clase==null) clase = "";
if(clase_desc==null) clase_desc = "";
if(fg==null) fg= "";
if(compRef==null) compRef= "";
if(index==null) index= "";

if(request.getMethod().equalsIgnoreCase("GET"))
{
int recsPerPage=100;
String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";

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

	sbFilter.append(" and a.estado = 'A'");
	if (!familia.trim().equals("")) { sbFilter.append(" and a.cod_flia = "); sbFilter.append(familia); }
	if (!codigo.trim().equals("")) { sbFilter.append(" and upper(a.subclase_id) like '%"); sbFilter.append(codigo.toUpperCase()); sbFilter.append("%'"); }
	if (!descripcion.trim().equals("")) { sbFilter.append(" and upper(a.descripcion) like '"); sbFilter.append(descripcion.toUpperCase()); sbFilter.append("%'"); }
	if (!clase.trim().equals("")) { sbFilter.append(" and upper(a.cod_clase) like '%"); sbFilter.append(clase.toUpperCase()); sbFilter.append("%'"); }
	if (!clase_desc.trim().equals("")) { sbFilter.append(" and exists (select null from tbl_inv_clase_articulo where cod_clase = a.cod_clase and cod_flia = a.cod_flia and compania = a.compania and upper(descripcion) like '"); sbFilter.append(clase_desc.toUpperCase()); sbFilter.append("%')"); }

	sbSql = new StringBuffer();
	sbSql.append("select * from (select rownum as rn, a.* from (");
		sbSql.append("select a.subclase_id, a.codigo, a.descripcion, a.estado, a.cod_clase as classCode, a.cod_flia as familyCode");
		sbSql.append(", (select descripcion from tbl_inv_clase_articulo where cod_clase = a.cod_clase and cod_flia = a.cod_flia and compania = a.compania) as clase");
		sbSql.append(", (select nombre from tbl_inv_familia_articulo where cod_flia = a.cod_flia and compania = a.compania) as familia");
		sbSql.append(", (select case when (select nvl(get_sec_comp_param(a.compania,'INV_CHK_FLIA_CONSIG'),'N') from dual) in ('Y','S') then nvl(consignacion,'N') else '-' end from tbl_inv_familia_articulo where cod_flia = a.cod_flia and compania = a.compania) as consignacion,(select nvl(costo_cero,'N') from tbl_inv_familia_articulo where cod_flia = a.cod_flia and compania = a.compania) as costoCero");
		sbSql.append(" from tbl_inv_subclase a where a.compania = ");
		if(!fg.trim().equals("MPFLIAREF"))sbSql.append(session.getAttribute("_companyId"));
		else sbSql.append(compRef);
		sbSql.append(sbFilter);
		sbSql.append(" order by 8,7,3");
	sbSql.append(") a) where rn between ");
	sbSql.append(previousVal);
	sbSql.append(" and ");
	sbSql.append(nextVal);
	al = SQLMgr.getDataList(sbSql);

	sbSql = new StringBuffer();
	sbSql.append("select count(*) from tbl_inv_subclase a where a.compania = ");
	if(!fg.trim().equals("MPFLIAREF"))sbSql.append(session.getAttribute("_companyId"));
	else sbSql.append(compRef);
	sbSql.append(sbFilter);
	rowCount = CmnMgr.getCount(sbSql.toString());

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
document.title = 'Lista de Subclases - '+document.title;

function returnValue(idx,existe)
{
<%if(fg.trim().equals("MPFLIA")){%>
if(existe=='1'){alert('El registro seleccionado ya está agregado en la lista . Favor Verifique!');}else{
window.opener.document.form0.familia<%=index%>.value=eval('document.form1.fcode'+idx).value;
window.opener.document.form0.familia_desc<%=index%>.value=eval('document.form1.fdesc'+idx).value;
window.opener.document.form0.clase<%=index%>.value=eval('document.form1.ccode'+idx).value;
window.opener.document.form0.clase_desc<%=index%>.value=eval('document.form1.cdesc'+idx).value;
window.opener.document.form0.sub_clase<%=index%>.value=eval('document.form1.scode'+idx).value;
window.opener.document.form0.sub_clase_desc<%=index%>.value=eval('document.form1.sdesc'+idx).value;
window.close();}
<%}else if(fg.trim().equals("MPFLIAREF")){%>
if(existe=='1'){alert('El registro seleccionado ya está agregado en la lista . Favor Verifique!');}else{
window.opener.document.form0.familia_ref<%=index%>.value=eval('document.form1.fcode'+idx).value;
window.opener.document.form0.flia_refDesc<%=index%>.value=eval('document.form1.fdesc'+idx).value;
window.opener.document.form0.clase_ref<%=index%>.value=eval('document.form1.ccode'+idx).value;
window.opener.document.form0.clase_refDesc<%=index%>.value=eval('document.form1.cdesc'+idx).value;
window.opener.document.form0.sub_clase_ref<%=index%>.value=eval('document.form1.scode'+idx).value;
window.opener.document.form0.sub_clase_ref_desc<%=index%>.value=eval('document.form1.sdesc'+idx).value;
window.close();}
<%}else if(fg.trim().equals("SALDO_INICIAL")){%>
if(existe=='1'){alert('El registro seleccionado ya está agregado en la lista . Favor Verifique!');}else{
window.opener.document.form1.familia.value=eval('document.form1.fcode'+idx).value;
window.opener.document.form1.familia_name.value=eval('document.form1.fdesc'+idx).value;
window.opener.document.form1.clase.value=eval('document.form1.ccode'+idx).value;
window.opener.document.form1.clase_name.value=eval('document.form1.cdesc'+idx).value;
window.opener.document.form1.subclase.value=eval('document.form1.scode'+idx).value;
window.opener.document.form1.subclase_name.value=eval('document.form1.sdesc'+idx).value;
window.close();}
<%}else{%>
//alert(cot);
window.opener.document.form1.familyCode.value=eval('document.form1.fcode'+idx).value;
window.opener.document.form1.familyName.value=eval('document.form1.fdesc'+idx).value;
window.opener.document.form1.classCode.value=eval('document.form1.ccode'+idx).value;
window.opener.document.form1.className.value=eval('document.form1.cdesc'+idx).value;
window.opener.document.form1.subClassCode.value=eval('document.form1.scode'+idx).value;
window.opener.document.form1.subClassName.value=eval('document.form1.sdesc'+idx).value;
window.opener.document.form1.costoCero.value=eval('document.form1.costoCero'+idx).value;
if(window.opener.document.form1.isAppropiation&&window.opener.document.form1.isAppropiation.checked&&eval('document.form1.consignacion'+idx).value=='N')window.opener.document.form1.isAppropiation.checked=false;
window.close();
//alert(cot);
<%}%>

}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - MANTENIMIENTO - SUBCLASE"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("search00",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("compRef",compRef)%>
		<tr class="TextFilter">
			<td>
				C&oacute;d. Familia<%=fb.textBox("familia",familia,false,false,false,10,null,null,null)%>
				C&oacute;d. Clase<%=fb.textBox("clase",clase,false,false,false,10,null,null,null)%>
				Desc. Clase<%=fb.textBox("clase_desc",clase_desc,false,false,false,30,null,null,null)%>
				C&oacute;d. Subclase<%=fb.textBox("codigo",codigo,false,false,false,10,null,null,null)%>
				Desc. Subclase<%=fb.textBox("descripcion",descripcion,false,false,false,30,null,null,null)%>
				<%=fb.submit("go","Ir")%>
			 </td>
		</tr>
<%=fb.formEnd()%>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("familia",familia)%>
<%=fb.hidden("clase",clase)%>
<%=fb.hidden("clase_desc",clase_desc)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("compRef",compRef)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("familia",familia)%>
<%=fb.hidden("clase",clase)%>
<%=fb.hidden("clase_desc",clase_desc)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("compRef",compRef)%>
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
			<td colspan="2">Familia</td>
			<td colspan="2">Clase</td>
			<td colspan="2">Subclase</td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="6%">C&oacute;d.</td>
			<td width="27%">Descripci&oacute;n</td>
			<td width="6%">C&oacute;d.</td>
			<td width="27%">Descripci&oacute;n</td>
			<td width="6%">C&oacute;d.</td>
			<td width="28%">Descripci&oacute;n</td>
		</tr>
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	String existe ="0";
	if(fg.trim().equals("MPFLIAREF")&& vClases.contains(cdo.getColValue("familyCode")+"-"+cdo.getColValue("classCode")+"-"+cdo.getColValue("subclase_id"))){ existe="1";}
%>
<%=fb.hidden("fcode"+i,cdo.getColValue("familyCode"))%>
<%=fb.hidden("fdesc"+i,cdo.getColValue("familia"))%>
<%=fb.hidden("ccode"+i,cdo.getColValue("classCode"))%>
<%=fb.hidden("cdesc"+i,cdo.getColValue("clase"))%>
<%=fb.hidden("scode"+i,cdo.getColValue("subclase_id"))%>
<%=fb.hidden("sdesc"+i,cdo.getColValue("descripcion"))%>
<%=fb.hidden("consignacion"+i,cdo.getColValue("consignacion"))%>
<%=fb.hidden("costoCero"+i,cdo.getColValue("costoCero"))%>

		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:returnValue(<%=i%>,<%=existe%>)" style="cursor:pointer">
			<td><%=cdo.getColValue("familyCode")%></td>
			<td><%=cdo.getColValue("familia")%></td>
			<td><%=cdo.getColValue("classCode")%></td>
			<td><%=cdo.getColValue("clase")%></td>
			<td><%=cdo.getColValue("subclase_id")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
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
<%fb = new FormBean("bottomPrevious",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("familia",familia)%>
<%=fb.hidden("clase",clase)%>
<%=fb.hidden("clase_desc",clase_desc)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("compRef",compRef)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("familia",familia)%>
<%=fb.hidden("clase",clase)%>
<%=fb.hidden("clase_desc",clase_desc)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("compRef",compRef)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td align="right"><%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
</tr>
</table>
</body>
</html>
<% } %>