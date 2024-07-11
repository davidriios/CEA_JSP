<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
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
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");
String audUser = request.getParameter("audUser");
String audAction = request.getParameter("audAction");
String familia = request.getParameter("familia");
String clase = request.getParameter("clase");
String articulo = request.getParameter("articulo");

if (fDate == null ) fDate = "";
if (tDate == null ) tDate = "";
if (audUser == null ) audUser = "";
if (audAction == null ) audAction = "";
if (familia == null ) familia = "";
if (clase == null ) clase = "";
if (articulo == null ) articulo = "";

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

	sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'AUD_SCHEMA'),'-') as schemaData from dual");
	CommonDataObject p = SQLMgr.getData(sbSql.toString());
	if (p.getColValue("schemaData").equals("-")) throw new Exception("El parámetro de auditoría [AUD_SCHEMA] no se encuentra definido!");
	String[] audschema = p.getColValue("schemaData").split(",");

	if (audAction.equalsIgnoreCase("INS")) {
		sbFilter.append(" and aud_action = 'INS'");
	} else if (audAction.equalsIgnoreCase("UPD")) {
		sbFilter.append(" and aud_action = 'UPD' and (cod_flia <> nvl(p_cod_flia,-999) or cod_clase <> nvl(p_cod_clase,-999) or descripcion <> nvl(p_descripcion,'NA') or cod_medida <> nvl(p_cod_medida,'---') or cod_medida_compra <> nvl(p_cod_medida_compra,'---') or precio_venta <> nvl(p_precio_venta,-1) or estado <> nvl(p_estado,'-'))");
	} else if (audAction.equalsIgnoreCase("FLIA")) {
		sbFilter.append(" and aud_action = 'UPD' and cod_flia <> p_cod_flia");
	} else if (audAction.equalsIgnoreCase("CLS")) {
		sbFilter.append(" and aud_action = 'UPD' and cod_clase <> p_cod_clase");
	} else if (audAction.equalsIgnoreCase("DESC")) {
		sbFilter.append(" and aud_action = 'UPD' and descripcion <> p_descripcion");
	} else if (audAction.equalsIgnoreCase("UM")) {
		sbFilter.append(" and aud_action = 'UPD' and cod_medida <> p_cod_medida");
	} else if (audAction.equalsIgnoreCase("UMC")) {
		sbFilter.append(" and aud_action = 'UPD' and cod_medida_compra <> p_cod_medida_compra");
	} else if (audAction.equalsIgnoreCase("PV")) {
		sbFilter.append(" and aud_action = 'UPD' and precio_venta <> p_precio_venta");
	} else if (audAction.equalsIgnoreCase("STS")) {
		sbFilter.append(" and aud_action = 'UPD' and estado <> p_estado");
	} else {
		sbFilter.append(" and (cod_flia <> nvl(p_cod_flia,-999) or cod_clase <> nvl(p_cod_clase,-999) or descripcion <> nvl(p_descripcion,'NA') or cod_medida <> nvl(p_cod_medida,'---') or cod_medida_compra <> nvl(p_cod_medida_compra,'---') or precio_venta <> nvl(p_precio_venta,-1) or estado <> nvl(p_estado,'-')/* or aud_action = 'DEL'*/)");
	}
	if (!fDate.trim().equals("")) { sbFilter.append(" and trunc(aud_timestamp) >= to_date('"); sbFilter.append(fDate); sbFilter.append("','dd/mm/yyyy')"); }
	if (!tDate.trim().equals("")) { sbFilter.append(" and trunc(aud_timestamp) <= to_date('"); sbFilter.append(tDate); sbFilter.append("','dd/mm/yyyy')"); }

	if (request.getParameter("articulo") != null) {
		sbSql = new StringBuffer();
		sbSql.append("select z.cod_flia, z.cod_clase, z.cod_subclase, z.cod_articulo, z.descripcion, z.cod_medida, z.cod_medida_compra, z.precio_venta, decode(z.estado,'A','ACTIVO','I','INACTIVO',z.estado) as estado, to_char(aud_timestamp,'dd/mm/yyyy hh24:mi:ss') as aud_date, z.aud_webuser_ip as aud_user, z.aud_action, nvl(z.p_cod_flia,z.cod_flia) as p_cod_flia, nvl(z.p_cod_clase,z.cod_clase) as p_cod_clase, nvl(z.p_cod_subclase,z.cod_subclase) as p_cod_subclase, nvl(z.p_descripcion,z.descripcion) as p_descripcion, nvl(z.p_cod_medida,z.cod_medida) as p_cod_medida, nvl(z.p_cod_medida_compra,z.cod_medida_compra) as p_cod_medida_compra, nvl(z.p_precio_venta,z.precio_venta) as p_precio_venta, decode(nvl(z.p_estado,z.estado),'A','ACTIVO','I','INACTIVO',nvl(z.p_estado,z.estado)) as p_estado");
		sbSql.append(", (select nombre from tbl_inv_familia_articulo where compania = z.compania and cod_flia = z.cod_flia) as familia");
		sbSql.append(", (select descripcion from tbl_inv_clase_articulo where compania = z.compania and cod_flia = z.cod_flia and cod_clase = z.cod_clase) as clase");
		sbSql.append(", (select nombre from tbl_inv_familia_articulo where compania = z.compania and cod_flia = nvl(z.p_cod_flia,z.cod_flia)) as p_familia");
		sbSql.append(", (select descripcion from tbl_inv_clase_articulo where compania = z.compania and cod_flia = nvl(z.p_cod_flia,z.cod_flia) and cod_clase = nvl(z.p_cod_clase,z.cod_clase)) as p_clase");
		sbSql.append(" from (");

		for (int i=0; i<audschema.length; i++) {
			if (i>0) sbSql.append(" union all ");
			sbSql.append("select compania, cod_flia, cod_clase, cod_subclase, cod_articulo, descripcion, cod_medida, other1 as cod_medida_compra, precio_venta, estado, aud_timestamp, aud_webuser_ip, aud_action");
			sbSql.append(", lag(cod_flia) over (partition by cod_articulo order by cod_articulo, aud_timestamp, decode(aud_action,'INS',1,'UPD',2,3)) as p_cod_flia");
			sbSql.append(", lag(cod_clase) over (partition by cod_articulo order by cod_articulo, aud_timestamp, decode(aud_action,'INS',1,'UPD',2,3)) as p_cod_clase");
			sbSql.append(", lag(cod_subclase) over (partition by cod_articulo order by cod_articulo, aud_timestamp, decode(aud_action,'INS',1,'UPD',2,3)) as p_cod_subclase");
			sbSql.append(", lag(descripcion) over (partition by cod_articulo order by cod_articulo, aud_timestamp, decode(aud_action,'INS',1,'UPD',2,3)) as p_descripcion");
			sbSql.append(", lag(cod_medida) over (partition by cod_articulo order by cod_articulo, aud_timestamp, decode(aud_action,'INS',1,'UPD',2,3)) as p_cod_medida");
			sbSql.append(", lag(other1) over (partition by cod_articulo order by cod_articulo, aud_timestamp, decode(aud_action,'INS',1,'UPD',2,3)) as p_cod_medida_compra");
			sbSql.append(", lag(precio_venta) over (partition by cod_articulo order by cod_articulo, aud_timestamp, decode(aud_action,'INS',1,'UPD',2,3)) as p_precio_venta");
			sbSql.append(", lag(estado) over (partition by cod_articulo order by cod_articulo, aud_timestamp, decode(aud_action,'INS',1,'UPD',2,3)) as p_estado");
			sbSql.append(" from ");
			sbSql.append(audschema[i].replaceAll("@@","."));
			sbSql.append("inv_articulo a where compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			if (!articulo.trim().equals("")) { sbSql.append(" and cod_articulo = "); sbSql.append(articulo); }
			if (!audUser.trim().equals("")) { sbSql.append(" and upper(aud_webuser_ip) like '%"); sbSql.append(audUser); sbSql.append("%'"); }
			if (!familia.trim().equals("") || !clase.trim().equals("")) {
				sbSql.append(" and exists (select null from tbl_inv_articulo where compania = a.compania and cod_articulo = a.cod_articulo");
				if (!familia.trim().equals("")) { sbSql.append(" and cod_flia = "); sbSql.append(familia); }
				if (!clase.trim().equals("")) { sbSql.append(" and cod_clase = "); sbSql.append(clase); }
				sbSql.append(")");
			}
		}

		sbSql.append(") z");
		if (sbFilter.length() != 0) sbSql.append(sbFilter.replace(0,4," where"));
		sbSql.append(" order by cod_articulo, aud_timestamp, decode(aud_action,'INS',1,'UPD',2,3)");

		StringBuffer sbTmp = new StringBuffer();
		sbTmp.append("select * from (select rownum as rn, a.* from (");
		sbTmp.append(sbSql);
		sbTmp.append(") a) where rn between ");
		sbTmp.append(previousVal);
		sbTmp.append(" and ");
		sbTmp.append(nextVal);
		al = SQLMgr.getDataList(sbTmp.toString());
		sbTmp = new StringBuffer();
		sbTmp.append("select count(*) from (");
		sbTmp.append(sbSql);
		sbTmp.append(")");
		rowCount = CmnMgr.getCount(sbTmp.toString());
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
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Inventario - Auditoría de Artículo - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function printList(){abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/aud_articulo.rptdesign&fDate=<%=fDate%>&tDate=<%=tDate%>&audUser=<%=audUser%>&audAction=<%=audAction%>&familia=<%=familia%>&clase=<%=clase%>&articulo=<%=articulo%>');}
</script>
<style type="text/css">
<!--
.txt-size::before {font-size: 20px !important;}
-->
</style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - AUDITORIA DE ARTICULO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right">&nbsp;</td>
</tr>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("searchMain",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<tr class="TextFilter">
	<td>
		<cellbytelabel>Aud. Fecha</cellbytelabel>
		<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="2"/>
		<jsp:param name="nameOfTBox1" value="fDate"/>
		<jsp:param name="valueOfTBox1" value="<%=fDate%>"/>
		<jsp:param name="nameOfTBox2" value="tDate"/>
		<jsp:param name="valueOfTBox2" value="<%=tDate%>"/>
		<jsp:param name="clearOption" value="true"/>
		</jsp:include>
		Aud. Usuario
		<%=fb.textBox("audUser",audUser,false,false,false,20,100,null,null,null)%>
		Aud. Acci&oacute;n
		<%=fb.select("audAction","INS=REGISTRADO,UPD=MODIFICADO,FLIA=CAMBIO FAMILIA,CLS=CAMBIO CLASE,DESC=CAMBIO DESCRIPCION,UM=CAMBIO UNIDAD,UMC=CAMBIO UNIDAD COMPRA,PV=CAMBIO PRECIO,STS=CAMBIO ESTADO",audAction,false,false,0,"",null,null,null,"T")%><br>
		Familia
		<%=fb.select("familia","","",false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/itemClass.xml','clase','"+clase+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T')\"")%>
		<script language="javascript">
		loadXML('../xml/itemFamily.xml','familia','<%=familia%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>','KEY_COL','T');
		</script>
		Clase
		<%=fb.select("clase","","")%>
		<script language="javascript">
		loadXML('../xml/itemClass.xml','clase','<%=clase%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%=(request.getParameter("familia") != null && !request.getParameter("familia").equals(""))?familia:"document.searchMain.familia.value"%>,'KEY_COL','T');
		</script>
		Art&iacute;culo
		<%=fb.textBox("articulo",articulo,false,false,false,15,null,null,null)%>
		<%=fb.submit("go","Ir")%>
	</td>
</tr>
<%=fb.formEnd()%>
<tr>
	<td align="right"><% if (request.getParameter("articulo") != null) { %><authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype><% } %>&nbsp;</td>
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
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("familia",familia)%>
<%=fb.hidden("clase",clase)%>
<%=fb.hidden("articulo",articulo)%>
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
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("familia",familia)%>
<%=fb.hidden("clase",clase)%>
<%=fb.hidden("articulo",articulo)%>
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
		<table align="center" width="100%" cellpadding="2" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="2%">&nbsp;</td>
			<td width="17%">Familia</td>
			<td width="17%">Clase</td>
			<td width="20%">Descripci&oacute;n</td>
			<td width="4%">UM</td>
			<td width="4%">UMC</td>
			<td width="5%">Precio</td>
			<td width="6%">Estado</td>
			<td width="8%">Aud. Fecha</td>
			<td width="17%">Aud. Usuario</td>
		</tr>
		<!--<tr class="TextRow00" align="center"><td colspan="9">TextRow00</td></tr>
		<tr class="TextRow01" align="center"><td colspan="9">TextRow01</td></tr>
		<tr class="TextRow02" align="center"><td colspan="9">TextRow02</td></tr>
		<tr class="TextRow03" align="center"><td colspan="9">TextRow03</td></tr>
		<tr class="TextRow04" align="center"><td colspan="9">TextRow04</td></tr>
		<tr class="TextRow05" align="center"><td colspan="9">TextRow05</td></tr>
		<tr class="TextRow06" align="center"><td colspan="9">TextRow06</td></tr>
		<tr class="TextRow07" align="center"><td colspan="9">TextRow07</td></tr>
		<tr class="TextRow08" align="center"><td colspan="9">TextRow08</td></tr>
		<tr class="TextRow09" align="center"><td colspan="9">TextRow09</td></tr>
		<tr class="TextRow10" align="center"><td colspan="9">TextRow10</td></tr>
		<tr class="TextRowYell" align="center"><td colspan="9">TextRowYell</td></tr>
		<tr class="TextRowWhite" align="center"><td colspan="9">TextRowWhite</td></tr>-->

<% if (request.getParameter("articulo") == null) { %>
		<tr class="TextRow01" align="center">
			<td colspan="10">&nbsp;</td>
		</tr>
		<tr class="TextRow01 RedText" align="center">
			<td colspan="10">I N T R O D U Z C A &nbsp;&nbsp;&nbsp; P A R A M E T R O S &nbsp;&nbsp;&nbsp; D E &nbsp;&nbsp;&nbsp; B U S Q U E D A</td>
		</tr>
		<tr class="TextRow01" align="center">
			<td colspan="10">&nbsp;</td>
		</tr>
<% } else if (al.size() == 0) { %>
		<tr class="TextRow01" align="center">
			<td colspan="10">&nbsp;</td>
		</tr>
		<tr class="TextRow01 RedText" align="center">
			<td colspan="10">B U S Q U E D A &nbsp;&nbsp;&nbsp; S I N &nbsp;&nbsp;&nbsp; R E S U L T A D O S</td>
		</tr>
		<tr class="TextRow01" align="center">
			<td colspan="10">&nbsp;</td>
		</tr>
<% } %>
<%
String g = "";
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

	if (!g.equalsIgnoreCase(cdo.getColValue("cod_articulo"))) {
%>
		<tr class="TextHeader01">
			<td colspan="10" align="center"><label class="Text14Bold SpacingText">CODIGO ARTICULO --> <%=cdo.getColValue("cod_articulo")%></label></td>
		</tr>
<% } %>
		<tr class="TextRow00<%=(cdo.getColValue("aud_action").equalsIgnoreCase("INS")?" RedTextBold":"")%>"><!-- onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')"-->
			<td align="center" rowspan="2" class="TextRow01 Text10Bold">
			<% if (cdo.getColValue("aud_action").equalsIgnoreCase("INS")) { %>
				<span class="span-circled span-circled-20 span-circled-green" data-content="+" style="--txt-size:20px"></span>
			<% } else if (cdo.getColValue("aud_action").equalsIgnoreCase("UPD")) { %>
				<span class="span-circled span-circled-20 span-circled-yellow" data-content="*" style="--txt-size:24px"></span>
			<% } else if (cdo.getColValue("aud_action").equalsIgnoreCase("DEL")) { %>
				<span class="span-circled span-circled-20 span-circled-red" data-content="-" style="--txt-size:24px"></span>
			<% } %>
			</td>
			<td><%=cdo.getColValue("p_familia")%></td>
			<td><%=cdo.getColValue("p_clase")%></td>
			<td><%=cdo.getColValue("p_descripcion")%></td>
			<td align="center"><%=cdo.getColValue("p_cod_medida")%></td>
			<td align="center"><%=cdo.getColValue("p_cod_medida_compra")%></td>
			<td align="right"><%=(cdo.getColValue("p_precio_venta").trim().equals(""))?"-":CmnMgr.getFormattedDecimal("###,##0.00",cdo.getColValue("p_precio_venta"))%></td>
			<td align="center"><%=cdo.getColValue("p_estado")%></td>
			<td align="center" rowspan="2" class="TextRow01 Text10Bold"><%=cdo.getColValue("aud_date")%></td>
			<td align="center" rowspan="2" class="TextRow01 Text10Bold"><%=cdo.getColValue("aud_user")%></td>
		</tr>
		<!--<tr class="TextRow01"><!-- onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')"-- >
			<td class="<%=(cdo.getColValue("p_familia").equals(cdo.getColValue("familia")))?"":"RedTextBold"%>"><%=cdo.getColValue("familia")%></td>
			<td class="<%=(cdo.getColValue("p_clase").equals(cdo.getColValue("clase")))?"":"RedTextBold"%>"><%=cdo.getColValue("clase")%></td>
			<td class="<%=(cdo.getColValue("p_descripcion").equals(cdo.getColValue("descripcion")))?"":"RedTextBold"%>"><%=cdo.getColValue("descripcion")%></td>
			<td class="<%=(cdo.getColValue("p_cod_medida").equals(cdo.getColValue("cod_medida")))?"":"RedTextBold"%>" align="center"><%=cdo.getColValue("cod_medida")%></td>
			<td class="<%=(cdo.getColValue("p_cod_medida_compra").equals(cdo.getColValue("cod_medida_compra")))?"":"RedTextBold"%>" align="center"><%=cdo.getColValue("cod_medida_compra")%></td>
			<td class="<%=(cdo.getColValue("p_precio_venta").equals(cdo.getColValue("precio_venta")))?"":"RedTextBold"%>" align="right"><%=(cdo.getColValue("precio_venta").trim().equals(""))?"-":CmnMgr.getFormattedDecimal("###,##0.00",cdo.getColValue("precio_venta"))%></td>
			<td class="<%=(cdo.getColValue("p_estado").equals(cdo.getColValue("estado")))?"":"RedTextBold"%>" align="center"><%=cdo.getColValue("estado")%></td>
		</tr>-->

		<tr class="TextRow01 RedTextBold"><!-- onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')"-->
			<td><%=(cdo.getColValue("p_familia").equals(cdo.getColValue("familia")))?"":cdo.getColValue("familia")%></td>
			<td><%=(cdo.getColValue("p_clase").equals(cdo.getColValue("clase")))?"":cdo.getColValue("clase")%></td>
			<td><%=(cdo.getColValue("p_descripcion").equals(cdo.getColValue("descripcion")))?"":cdo.getColValue("descripcion")%></td>
			<td align="center"><%=(cdo.getColValue("p_cod_medida").equals(cdo.getColValue("cod_medida")))?"":cdo.getColValue("cod_medida")%></td>
			<td align="center"><%=(cdo.getColValue("p_cod_medida_compra").equals(cdo.getColValue("cod_medida_compra")))?"":cdo.getColValue("cod_medida_compra")%></td>
			<td align="right"><%=(cdo.getColValue("p_precio_venta").equals(cdo.getColValue("precio_venta")))?"":((cdo.getColValue("precio_venta").trim().equals(""))?"-":CmnMgr.getFormattedDecimal("###,##0.00",cdo.getColValue("precio_venta")))%></td>
			<td align="center"><%=(cdo.getColValue("p_estado").equals(cdo.getColValue("estado")))?"":cdo.getColValue("estado")%></td>
		</tr>
<%
	g = cdo.getColValue("cod_articulo");
}
%>
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
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("familia",familia)%>
<%=fb.hidden("clase",clase)%>
<%=fb.hidden("articulo",articulo)%>
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
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("familia",familia)%>
<%=fb.hidden("clase",clase)%>
<%=fb.hidden("articulo",articulo)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="Text10">
		<span class="span-circled span-circled-20 span-circled-green" data-content="+" style="--txt-size:20px"></span>REGISTRADO
		<span class="span-circled span-circled-20 span-circled-yellow" data-content="*" style="--txt-size:24px"></span>MODIFICADO
		<!--<span class="span-circled span-circled-20 span-circled-red" data-content="-" style="--txt-size:24px"></span>ELIMINADO-->
	</td>
</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<% } %>
