<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.expediente.DetalleOrdenMed"%>
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
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String index = request.getParameter("index");
String cama = request.getParameter("cama");
String habitacion = request.getParameter("habitacion");
String sala = request.getParameter("sala");

if (fg == null) fg = "";
if (cama == null) cama = "";
if (habitacion == null) habitacion = "";
if (sala == null) sala = "";

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
	if (!cama.trim().equals("")) { sbFilter.append(" and upper(a.codigo) like '%"); sbFilter.append(cama.toUpperCase()); sbFilter.append("%'"); }
	if (!habitacion.trim().equals("")) { sbFilter.append(" and upper(a.habitacion) like '%"); sbFilter.append(habitacion.toUpperCase()); sbFilter.append("%'"); }
	if (!sala.trim().equals("")) { sbFilter.append(" and exists (select null from tbl_cds_centro_servicio where codigo = b.unidad_admin and compania_unorg = a.compania and upper(descripcion) like '%"); sbFilter.append(sala.toUpperCase()); sbFilter.append("%')"); }

	if (fp.equalsIgnoreCase("reasignar_cama")) {

		sbSql.append("select a.codigo cama, a.habitacion, b.unidad_admin cod_sala, (select descripcion from tbl_cds_centro_servicio where codigo = b.unidad_admin and compania_unorg = a.compania) desc_sala, b.estado_habitacion as estado_hab, a.estado_cama, (select count(*) tot from tbl_sal_cargos_automaticos aa where aa.habitacion = a.habitacion and aa.cama = a.codigo) as has_caut from tbl_sal_cama a, tbl_sal_habitacion b where a.compania = b.compania and a.habitacion = b.codigo and a.estado_cama = 'D' and a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(sbFilter);
		sbSql.append(" order by b.unidad_admin, a.habitacion, a.estado_cama");

	}

	if (sbSql.length() != 0) {

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
document.title = 'Centro de Servicio - '+document.title;
function setCama(i){
<% if (fp.equalsIgnoreCase("reasignar_cama")) { %>
	window.opener.document.form1.cama.value = eval('document.camas.cama'+i).value;
	window.opener.document.form1.habitacion.value = eval('document.camas.habitacion'+i).value;
	window.opener.document.form1.cod_sala.value = eval('document.camas.cod_sala'+i).value;
	window.opener.document.form1.desc_sala.value = eval('document.camas.desc_sala'+i).value;
<% } %>
	window.close();
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE HABITACION/CAMA"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextFilter">
				<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("index",index)%>
				<td width="33%">
					<cellbytelabel>Cama</cellbytelabel>
					<%=fb.intBox("cama","",false,false,false,20)%>
				</td>
				<td width="33%">
					<cellbytelabel>Habitaci&oacute;n</cellbytelabel>
					<%=fb.intBox("habitacion","",false,false,false,20)%>
				</td>
				<td width="34%">
					<cellbytelabel>Sala</cellbytelabel>
					<%=fb.textBox("sala","",false,false,false,20)%>
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
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
<%
fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
%>
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
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("cama",cama)%>
					<%=fb.hidden("habitacion",habitacion)%>
					<%=fb.hidden("sala",sala)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
<%
fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
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
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("cama",cama)%>
					<%=fb.hidden("habitacion",habitacion)%>
					<%=fb.hidden("sala",sala)%>
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
<%fb = new FormBean("camas",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart()%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="20%"><cellbytelabel>Cama</cellbytelabel></td>
					<td width="15%"><cellbytelabel>Cargos Aut.</cellbytelabel></td>
					<td width="30%"><cellbytelabel>Habitaci&oacute;n</cellbytelabel></td>
					<td width="35%"><cellbytelabel>Sala</cellbytelabel></td>
				</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
				<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("cama"+i,cdo.getColValue("cama"))%>
				<%=fb.hidden("habitacion"+i,cdo.getColValue("habitacion"))%>
				<%=fb.hidden("cod_sala"+i,cdo.getColValue("cod_sala"))%>
				<%=fb.hidden("desc_sala"+i,cdo.getColValue("desc_sala"))%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setCama(<%=i%>);" style="cursor:pointer">
					<td align="center"><%=cdo.getColValue("cama")%></td>
					<td align="center"><%=cdo.getColValue("has_caut")!=null && !cdo.getColValue("has_caut").equals("0")?"SI":""%></td>
					<td align="center"><%=cdo.getColValue("habitacion")%></td>
					<td><%=cdo.getColValue("cod_sala")%>&nbsp;&nbsp;<%=cdo.getColValue("desc_sala")%></td>
				</tr>
<%
}
%>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.formEnd()%>
			</table>
</div>
</div>
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
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("cama",cama)%>
					<%=fb.hidden("habitacion",habitacion)%>
					<%=fb.hidden("sala",sala)%>
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
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("cama",cama)%>
					<%=fb.hidden("habitacion",habitacion)%>
					<%=fb.hidden("sala",sala)%>
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
<%}%>