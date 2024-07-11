<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Vector" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%
/**
===============================================================================
PRESF009
===============================================================================
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
String unidad = request.getParameter("unidad");
String anio = request.getParameter("anio");

if (unidad == null) unidad = "";
if (anio == null) anio = "";

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

	if (!unidad.trim().equals("")) { sbFilter.append(" and a.codigo_ue = "); sbFilter.append(unidad); }
	if (!anio.trim().equals("")) { sbFilter.append(" and a.anio = "); sbFilter.append(anio); }

/*  se omite el join  **and a.codigo_ue in(**  para manejar por el parametro NIVEL_UNIDAD_PRESUPUESTO que solo se maneje por nivel  */

	/*
	if(!UserDet.getUserProfile().contains("0")){
	if(session.getAttribute("_ua")!=null){
	sbFilter.append(" and a.codigo_ue in (");
	sbFilter.append(CmnMgr.vector2numSqlInClause((Vector)session.getAttribute("_ua")));
	sbFilter.append(")");}
	else sbFilter.append(" and a.codigo_ue in (-1)");
	}
	*/
	
	sbSql = new StringBuffer();
	sbSql.append("select a.anio, a.tipo_inv, a.compania, a.codigo_ue, a.consec, a.descripcion, decode(a.categoria,1,'GENERADOR DE INGRESOS',2,'APOYO OPERATIVO',3,'APOYO ADMINISTRATIVO') as categoria, a.cantidad, decode(a.prioridad,1,'URGENTE',2,'MUY NECESARIO',3,'NECESARIO') as prioridad, a.codigo_proveedor, (select nombre_proveedor from tbl_com_proveedor where compania = a.compania and cod_provedor = a.codigo_proveedor) as descProveedor, a.origen, (select descripcion from tbl_sec_unidad_ejec where codigo = a.codigo_ue and compania = a.compania) as descUnidad, (select descripcion from tbl_con_tipo_inversion where tipo_inv = a.tipo_inv and compania = a.compania) as tipo_inv_desc from tbl_con_inversion_anual a where a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(sbFilter);
	sbSql.append(" order by 1 desc, 2, 5, descUnidad");

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from tbl_con_inversion_anual a where a.compania = "+session.getAttribute("_companyId")+sbFilter);

	sbSql = new StringBuffer();
	sbSql.append("select a.codigo, a.descripcion||' - '||a.codigo, a.codigo from tbl_sec_unidad_ejec a, tbl_con_pres_fusion b where a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	
	/*  se omite el join  **and a.codigo_ue in(**  para manejar por el parametro NIVEL_UNIDAD_PRESUPUESTO que solo se maneje por nivel  */

/*
	if(!UserDet.getUserProfile().contains("0")){
	if(session.getAttribute("_ua")!=null){
	sbSql.append(" and a.codigo in (");
	sbSql.append(CmnMgr.vector2numSqlInClause((Vector)session.getAttribute("_ua")));
	sbSql.append(")");}
	else sbSql.append(" and a.codigo in (-1)");
	}
*/
	sbSql.append(" and a.nivel in (select column_value  from table( select split((select get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'NIVEL_UNIDAD_PRESUPUESTO') from dual),',') from dual  )) /* and a.codigo < 100 */ and a.compania = b.compania(+) and a.codigo= b.unidad(+) and b.unidad is null order by 2");

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
document.title = 'Presupuesto De Inversiones - '+document.title;
function printPres(anio,unidad,consec){abrir_ventana('../presupuesto/print_list_inv_anual_dist_mens.jsp?anio='+anio+'&unidad='+unidad+'&consec='+consec);}
function getInvMensual(anio,tipoInv,unidad,consec){showPopWin('../presupuesto/list_inv_anual_dist_mens_det.jsp?anio='+anio+'&tipoInv='+tipoInv+'&unidad='+unidad+'&consec='+consec,winWidth*.75,_contentHeight*.8,null,null,'');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PRESUPUESTO DE INVERSIONES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<tr class="TextFilter">
	<td>
		<cellbytelabel>Unidad</cellbytelabel>
		<%=fb.select(ConMgr.getConnection(),sbSql.toString(),"unidad",unidad,false,false,0,"Text10",null,null,null,"T")%>
		<cellbytelabel>A&ntilde;o</cellbytelabel>
		<%=fb.intBox("anio",anio,false,false,false,10,"Text10",null,"onFocus=\"this.select()\"")%>
		<%=fb.submit("go","Ir",true,false,"Text10",null,null)%>
	</td>
</tr>
<%=fb.formEnd(true)%>
<tr>
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td class="TableBorder">
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
<%=fb.hidden("unidad",unidad)%>
<%=fb.hidden("anio",anio)%>
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
<%=fb.hidden("unidad",unidad)%>
<%=fb.hidden("anio",anio)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="3%">&nbsp;</td>
			<td width="17%"><cellbytelabel>Tipo Inversi&oacute;n</cellbytelabel></td>
			<td width="35%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="27%"><cellbytelabel>Categor&iacute;a</cellbytelabel></td>
			<td width="15%"><cellbytelabel>Prioridad</cellbytelabel></td>
			<td width="3%">&nbsp;</td>
		</tr>
<%
String key = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
	<% if (!key.equalsIgnoreCase(cdo.getColValue("anio")+"-"+cdo.getColValue("codigo_ue"))) { %>
		<tr class="TextHeader01">
			<td colspan="4"><cellbytelabel>Unidad Administrativa</cellbytelabel>: <%="["+cdo.getColValue("codigo_ue")+"] "+cdo.getColValue("descUnidad")%></td>
			<td align="right"><cellbytelabel>A&ntilde;o</cellbytelabel>: <%=cdo.getColValue("anio")%></td>
			<td align="center"><a href="javascript:printPres('<%=cdo.getColValue("anio")%>','<%=cdo.getColValue("codigo_ue")%>','<%=cdo.getColValue("consec")%>')" class="Link02Bold"><img src="../images/printer.gif" width="20" height="20" border="0" alt="Imprimir"></a></td>
		</tr>
	<% } %>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("consec")%></td>
			<td><%=cdo.getColValue("tipo_inv_desc")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td><%=cdo.getColValue("categoria")%></td>
			<td align="center"><%=cdo.getColValue("prioridad")%></td>
			<td align="center"><a href="javascript:getInvMensual('<%=cdo.getColValue("anio")%>','<%=cdo.getColValue("tipo_inv")%>','<%=cdo.getColValue("codigo_ue")%>','<%=cdo.getColValue("consec")%>')" class="Link02Bold"><img src="../images/search.gif" width="20" height="20" border="0" alt="Ver Detalle"></a></td>
			
			
			
		</tr>
<%
	key = cdo.getColValue("anio")+"-"+cdo.getColValue("codigo_ue");
}
%>
		</table>
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
<%=fb.hidden("unidad",unidad)%>
<%=fb.hidden("anio",anio)%>
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
<%=fb.hidden("unidad",unidad)%>
<%=fb.hidden("anio",anio)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>