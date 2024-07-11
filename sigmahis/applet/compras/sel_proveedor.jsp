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
==========================================================================================
==========================================================================================
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
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");

if (fp == null) fp = "";
//if (fp.trim().equals("")) appendFilter = " where tipo_prove='IN'";

//if (fp.trim().equals("OC")) appendFilter = " where estado_proveedor='ACT'";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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
	String cod_provedor="",nombre_proveedor="";
	if (request.getParameter("cod_provedor") != null && !request.getParameter("cod_provedor").trim().equals(""))
	{
		appendFilter += " and upper(cod_provedor) like '%"+request.getParameter("cod_provedor").toUpperCase()+"%'";
			cod_provedor = request.getParameter("cod_provedor");
	}
	if (request.getParameter("nombre_proveedor") != null && !request.getParameter("nombre_proveedor").trim().equals(""))
	{
		appendFilter += " and upper(nombre_proveedor) like '%"+request.getParameter("nombre_proveedor").toUpperCase()+"%'";
			nombre_proveedor = request.getParameter("nombre_proveedor");
	}
	sql = "select cod_provedor, nombre_proveedor, ruc, tipo_pago, dia_limite from tbl_com_proveedor where compania = "+session.getAttribute("_companyId")+" and estado_proveedor='ACT' "+appendFilter+"  and vetado='N' order by nombre_proveedor, ruc";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from ("+sql+")");

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
document.title = 'Inventario - '+document.title;

function setValues(i)
{
<%
	if (fp.trim().equals(""))
	{
%>
	window.opener.document.ordencompra.cod_proveedor.value = eval('document.detail.code'+i).value;
	window.opener.document.ordencompra.desc_cod_proveedor.value = eval('document.detail.desc'+i).value;
	window.opener.document.ordencompra.ruc.value = eval('document.detail.ruc'+i).value;
	window.opener.document.ordencompra.tipo_pago.value = eval('document.detail.tipo_pago'+i).value;
	window.opener.document.ordencompra.diaLimite.value = eval('document.detail.diaLimite'+i).value;


	<%
	}
	else if (fp.equalsIgnoreCase("DF") || fp.equalsIgnoreCase("RF") || fp.equalsIgnoreCase("RP") || fp.equalsIgnoreCase("OC"))
	{
%>
	window.opener.document.form0.codProv.value = eval('document.detail.code'+i).value;
	window.opener.document.form0.descProv.value = eval('document.detail.desc'+i).value;
<%
	}
	else if (fp.equalsIgnoreCase("PR"))
	{
%>
	window.opener.document.form1.codProveedorPrim.value = eval('document.detail.code'+i).value;
	window.opener.document.form1.desProveedorPrim.value = eval('document.detail.desc'+i).value;
<%
	}
	else if (fp.equalsIgnoreCase("SE"))
	{
%>
	window.opener.document.form1.codProveedorSecu.value = eval('document.detail.code'+i).value;
	window.opener.document.form1.desProveedorSecu.value = eval('document.detail.desc'+i).value;

<%
}
	else if (fp.equalsIgnoreCase("sol_punto_reorden"))
	{
%>
	window.opener.document.search01.proveedor.value = eval('document.detail.code'+i).value;
	window.opener.document.search01.proveedor_desc.value = eval('document.detail.desc'+i).value;
<%}%>
	window.close();
}
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="COMPRAS - SELECCION DE PROVEEDOR"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
			<td width="33%">
				<cellbytelabel>C&oacute;digo</cellbytelabel>
				<%=fb.intBox("cod_provedor","",false,false,false,30)%>
			</td>
			<td width="34%">
				<cellbytelabel>Descripci&oacute;n</cellbytelabel>
				<%=fb.textBox("nombre_proveedor","",false,false,false,30)%>
				<%=fb.submit("go","Ir")%>
			</td>
			<%=fb.formEnd(true)%>
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
<%=fb.hidden("cod_provedor",cod_provedor)%>
<%=fb.hidden("nombre_proveedor",nombre_proveedor)%>
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
<%=fb.hidden("cod_provedor",cod_provedor)%>
<%=fb.hidden("nombre_proveedor",nombre_proveedor)%>
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
			<td width="5%">&nbsp;</td>
			<td width="20%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="40%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Tipo Pago</cellbytelabel></td>
			<td width="10%"><cellbytelabel>D&iacute;a L&iacute;mite</cellbytelabel></td>
			<td width="15%">&nbsp;</td>
		</tr>
<%fb = new FormBean("detail","");%>
<%=fb.formStart()%>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("code"+i,cdo.getColValue("cod_provedor"))%>
		<%=fb.hidden("desc"+i,cdo.getColValue("nombre_proveedor"))%>
		<%=fb.hidden("ruc"+i,cdo.getColValue("ruc"))%>
		<%=fb.hidden("tipo_pago"+i,cdo.getColValue("tipo_pago"))%>
		<%=fb.hidden("diaLimite"+i,cdo.getColValue("dia_limite"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setValues(<%=i%>)" style="cursor:pointer">
			<td align="right"><%//=preVal + i%>&nbsp;</td>
			<td><%=cdo.getColValue("cod_provedor")%></td>
			<td><%=cdo.getColValue("nombre_proveedor")%></td>

<%
String tipoPago="";
if (cdo.getColValue("tipo_pago").equals("0")) tipoPago=("Seleccione");
else if (cdo.getColValue("tipo_pago").equals("1")) tipoPago=("Contado");
else if (cdo.getColValue("tipo_pago").equals("2")) tipoPago=("Credito");
%>
			<td  align="center"><%=tipoPago%></td>
<%	String diaLimite="";
if (cdo.getColValue("dia_limite").equals("0")) diaLimite=("Seleccione");
else if (cdo.getColValue("dia_limite").equals("1")) diaLimite=("15 Dias");
else if (cdo.getColValue("dia_limite").equals("2")) diaLimite=("30 Dias");
else if (cdo.getColValue("dia_limite").equals("3")) diaLimite=("45 Dias");
else if (cdo.getColValue("dia_limite").equals("4")) diaLimite=("60 Dias");
else if (cdo.getColValue("dia_limite").equals("5")) diaLimite=("90 Dias");
else if (cdo.getColValue("dia_limite").equals("6")) diaLimite=("120 Dias");
%>
			<td align="center"><%=diaLimite%></td>
			<td align="center">&nbsp;</td>
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
<%=fb.hidden("cod_provedor",cod_provedor)%>
<%=fb.hidden("nombre_proveedor",nombre_proveedor)%>
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
<%=fb.hidden("cod_provedor",cod_provedor)%>
<%=fb.hidden("nombre_proveedor",nombre_proveedor)%>
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