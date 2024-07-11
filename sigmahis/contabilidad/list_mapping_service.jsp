<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.contabilidad.AccountMap"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="IXml" scope="page" class="issi.admin.XMLCreator"/>
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
IXml.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList alCds = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String cds = request.getParameter("cds");
String serviceType = request.getParameter("serviceType");
String categoria = request.getParameter("categoria");

sbSql.append("select a.tipo_servicio as value_col, (select descripcion from tbl_cds_tipo_servicio where codigo = a.tipo_servicio)||' [ '||a.tipo_servicio||' ]' as label_col, a.centro_servicio as key_col from tbl_cds_servicios_x_centros a where exists (select null from tbl_cds_centro_servicio where codigo = a.centro_servicio and compania_unorg = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(") order by 2");
IXml.create(java.util.ResourceBundle.getBundle("path").getString("xml")+"/cdsService.xml",sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select a.codigo as optValueColumn, a.descripcion||' [ '||a.codigo||' ]' as optLabelColumn from tbl_cds_centro_servicio a where a.compania_unorg = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and exists (select null from tbl_cds_servicios_x_centros where centro_servicio = a.codigo) order by 2");
System.out.println("SQL=\n"+sbSql);
alCds = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CommonDataObject.class);

if (cds == null) {
	if (alCds.size() != 0) cds = ((CommonDataObject) alCds.get(0)).getOptValueColumn();
	else cds = "";
}
if (serviceType == null) serviceType = "";
if (categoria == null) categoria = "";
if (!serviceType.trim().equals("")) { sbFilter.append(" and a.service_type = '"); sbFilter.append(serviceType); sbFilter.append("'"); }
if (!categoria.trim().equals("")) { sbFilter.append(" and a.adm_type = '"); sbFilter.append(categoria); sbFilter.append("'"); }

String refTable = request.getParameter("refTable");
String refPk = request.getParameter("refPk");
if (refTable == null) refTable = "";
if (refPk == null) refPk = "";

if(request.getMethod().equalsIgnoreCase("GET")) {
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

	if (!refTable.trim().equals("")) { sbFilter.append(" and upper(a.ref_table) = '"); sbFilter.append(refTable.toUpperCase()); sbFilter.append("'"); }
	if (!refPk.trim().equals("")) { sbFilter.append(" and upper(a.ref_pk) like '%"); sbFilter.append(refPk.toUpperCase()); sbFilter.append("%'"); }

	sbSql = new StringBuffer();
	sbSql.append("select distinct a.cds, a.service_type as serviceType, a.ref_table as refTable, a.ref_pk as refPk, b.cds_desc as cdsDesc, nvl(b.service_type_desc,'NO APLICA') as serviceTypeDesc, nvl(a.adm_type,'T') as admType from tbl_con_accdef a, (");
		sbSql.append("select codigo as cds, descripcion as cds_desc, '-' as service_type, '-' as service_type_desc from tbl_cds_centro_servicio where compania_unorg = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" union all ");
		sbSql.append("select a.codigo, a.descripcion, c.codigo, c.descripcion from tbl_cds_centro_servicio a, tbl_cds_servicios_x_centros b, tbl_cds_tipo_servicio c where a.codigo = b.centro_servicio and b.tipo_servicio = c.codigo and a.compania_unorg = ");
		sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(") b where a.cds = b.cds and a.service_type = b.service_type and a.cds = ");
	sbSql.append(cds);
	sbSql.append(sbFilter);
	sbSql.append(" order by a.cds, a.service_type, a.ref_table, a.ref_pk");
	System.out.println("SQL=\n"+sbSql.toString());
	al = sbb.getBeanList(ConMgr.getConnection(),"select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal,AccountMap.class);
	rowCount = CmnMgr.getCount("select count(*) from ("+sbSql+")");

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
document.title = 'Mapping de Cuentas x Servicio - '+document.title;
function add(){abrir_ventana('../contabilidad/mapping_service.jsp');}
function edit(cds,serviceType,refTable,refPk,admType){abrir_ventana('../contabilidad/mapping_service.jsp?mode=edit&cds='+cds+'&serviceType='+serviceType+'&refTable='+refTable+'&refPk='+refPk+'&admType='+admType);}
function printList(){abrir_ventana('../contabilidad/print_list_mapping_service.jsp');}
function loadTS(){loadXML('../xml/cdsService.xml','serviceType','<%=serviceType%>','VALUE_COL','LABEL_COL','<%=cds%>','KEY_COL','T')}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();loadTS();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="LISTA DE SERVICIOS CON MAPPING"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right">&nbsp;<authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nuevo Mapping de Cuentas x Servicio ]</a></authtype></td>
</tr>
<tr>
	<td align="center">
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<td>
				Centro Servicio
				<%=fb.select("cds",alCds,cds,false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/cdsService.xml','serviceType','"+serviceType+"','VALUE_COL','LABEL_COL',this.value,'KEY_COL','T')\"")%>
				Tipo Servicio
				<%=fb.select("serviceType","","")%>
				Cat. Ingreso:
				<%=fb.select(ConMgr.getConnection(),"select distinct adm_type,decode(adm_type,'I','INGRESOS - IP','INGRESOS - OP') categoria from tbl_adm_categoria_admision order by 1","categoria",categoria,"T")%>
			</td>
		</tr>
		<tr class="TextFilter">
			<td>
				Tipo Referencia
				<%=fb.select("refTable","-=NO APLICA,TBL_CDS_PROCEDIMIENTO=PROCEDIMIENTO,TBL_FAC_OTROS_CARGOS=OTROS CARGOS,TBL_CDS_PRODUCTO_X_CDS=PRODUCTO X CDS,TBL_SAL_HABITACION=HABITACION,TBL_INV_ARTICULO=ARTICULO,TBL_SAL_USO=USO,TBL_ADM_MEDICO=MEDICO,TBL_ADM_EMPRESA=EMPRESA","","T")%>
				Referencia
				<%=fb.textBox("refPk","",false,false,false,40)%>
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
	<td class="RedTextBold" align="left">PARA OTROS INGRESOS DE POS EN MAPPING NO DEBES ESCOGER CATEGORIA DE ADMISION IP/OP DEBE SER TODOS</td>
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
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("serviceType",serviceType)%>
<%=fb.hidden("categoria",categoria)%>
<%=fb.hidden("refTable",refTable)%>
<%=fb.hidden("refPk",refPk)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("serviceType",serviceType)%>
<%=fb.hidden("categoria",categoria)%>
<%=fb.hidden("refTable",refTable)%>
<%=fb.hidden("refPk",refPk)%>
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
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="25%">Centro de Servicio</td>
			<td width="25%">Tipo de Servicio</td>
			<td width="20%">Tabla de Referencia</td>
			<td width="20%">Referencia</td>
			<td width="10%">&nbsp;</td>
		</tr>
<%
String refer = "";
for (int i=0; i<al.size(); i++) {
	AccountMap am = (AccountMap) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

	if (am.getRefTable().equalsIgnoreCase("-")) refer = "NO APLICA";
	else if (am.getRefTable().equalsIgnoreCase("TBL_CDS_PROCEDIMIENTO")) refer = "PROCEDIMIENTO";
	else if (am.getRefTable().equalsIgnoreCase("TBL_FAC_OTROS_CARGOS")) refer = "OTROS CARGOS";
	else if (am.getRefTable().equalsIgnoreCase("TBL_CDS_PRODUCTO_X_CDS")) refer = "PRODUCTO X CDS";
	else if (am.getRefTable().equalsIgnoreCase("TBL_SAL_HABITACION")) refer = "HABITACION";
	else if (am.getRefTable().equalsIgnoreCase("TBL_INV_ARTICULO")) refer = "ARTICULO";
	else if (am.getRefTable().equalsIgnoreCase("TBL_SAL_USO")) refer = "USO";
	else if (am.getRefTable().equalsIgnoreCase("TBL_ADM_MEDICO")) refer = "MEDICO";
	else if (am.getRefTable().equalsIgnoreCase("TBL_ADM_EMPRESA")) refer = "EMPRESA";
	else refer = am.getRefTable();
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td>[<%=am.getCds()%>] <%=am.getCdsDesc()%></td>
			<td><%=(am.getServiceType().trim().equals("-"))?am.getServiceType():"["+am.getServiceType()+"] "+am.getServiceTypeDesc()%></td>
			<td><%=refer%></td>
			<td><%=am.getRefPk()%></td>
			<td align="center"><a href="javascript:edit(<%=am.getCds()%>,'<%=am.getServiceType()%>','<%=am.getRefTable()%>','<%=am.getRefPk()%>','<%=am.getAdmType()%>')" class="Link02Bold">Ver Cuentas</a></td>
		</tr>
<% } %>
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
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("serviceType",serviceType)%>
<%=fb.hidden("categoria",categoria)%>
<%=fb.hidden("refTable",refTable)%>
<%=fb.hidden("refPk",refPk)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("serviceType",serviceType)%>
<%=fb.hidden("categoria",categoria)%>
<%=fb.hidden("refTable",refTable)%>
<%=fb.hidden("refPk",refPk)%>
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
<% } %>
