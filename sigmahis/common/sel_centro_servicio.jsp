<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="XML" scope="page" class="issi.admin.XMLCreator" />
<jsp:useBean id="fTranCarg" scope="session" class="java.util.Hashtable" />
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
XML.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String cs = request.getParameter("cs");
String categoria = request.getParameter("categoria");
String estado = request.getParameter("estado");

if (fg == null) fg = "";
if (cs == null) cs = "";
if (categoria == null) categoria = "";
if (estado == null) estado = "";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null){
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}
	String codigo ="",descripcion="";
	if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals("")){
		appendFilter += " and upper(a.codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
		codigo = request.getParameter("codigo");
	}
	if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals("")){
		appendFilter += " and upper(a.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
		descripcion = request.getParameter("descripcion");
	} 

	if(fg.equals("PAC")){
		sql = "select codigo, descripcion, tipo_cds, reporta_a, nvl(incremento,0) incremento, nvl(tipo_incremento, ' ') tipo_incremento from tbl_cds_centro_servicio a where estado = 'A' and codigo not in ( select column_value  from table( select split((select param_value from tbl_sec_comp_param where compania in(-1,"+(String) session.getAttribute("_companyId")+") and param_name='CDS_HON'),',') from dual  ))   ";
		if(!UserDet.getUserProfile().contains("0"))
			if(session.getAttribute("_cds") != null)sql += " and codigo in ("+CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_cds"))+")";
			else  sql += " and codigo in(-1)";
		sql += appendFilter+" order by descripcion";
	} else if(fg.equals("FH")){
		sql = "select codigo, descripcion, tipo_cds, reporta_a, nvl(incremento,0) incremento, nvl(tipo_incremento, ' ') tipo_incremento from tbl_cds_centro_servicio a where compania_unorg = "+(String) session.getAttribute("_companyId")+" and estado = 'A' and codigo in (2, 5, 6, 9, 10, 11 , 20, 21, 22, 39, 70, 101, 102, 103, 104, 105) "+appendFilter+" order by descripcion";
	} else if(fg.equals("HON")){
		sql = "select codigo, descripcion, tipo_cds, reporta_a, nvl(incremento,0) incremento, nvl(tipo_incremento, ' ') tipo_incremento from tbl_cds_centro_servicio a where compania_unorg = "+ (String) session.getAttribute("_companyId") +" and codigo  in ( select column_value  from table( select split((select param_value from tbl_sec_comp_param where compania in(-1,"+(String) session.getAttribute("_companyId")+") and param_name='CDS_HON'),',') from dual  )) ";
	}else if(fg.equals("MAPPING_CPT")){
		sql = "select codigo, descripcion, tipo_cds, reporta_a, nvl(incremento,0) incremento, nvl(tipo_incremento, ' ') tipo_incremento from tbl_cds_centro_servicio a where compania_unorg = "+ (String) session.getAttribute("_companyId") +" and estado = 'A' ";
	}

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");

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
function setTipoAdmision(k){
	var cs = document.centroServicio.cs.value;
	var size = '<%=fTranCarg.size()%>';
<%
	if (fg.equalsIgnoreCase("PAC") || fg.equalsIgnoreCase("FH")){
%>
	window.opener.document.form0.centroServicio.value = eval('document.centroServicio.centroServicio'+k).value;
	window.opener.document.form0.centroServicioDesc.value = eval('document.centroServicio.centroServicioDesc'+k).value;
	window.opener.document.form0.tipoCds.value = eval('document.centroServicio.tipoCds'+k).value;
	window.opener.document.form0.reportaA.value = eval('document.centroServicio.reportaA'+k).value;
	window.opener.document.form0.incremento.value = eval('document.centroServicio.incremento'+k).value;
	window.opener.document.form0.tipoInc.value = eval('document.centroServicio.tipo_incremento'+k).value;
	if(window.opener.document.form0.almacen)window.opener.loadXML('../xml/almacen_x_cds_<%=UserDet.getUserId()%>.xml','almacen','','VALUE_COL','LABEL_COL','<%=session.getAttribute("_companyId")%>-'+eval('document.centroServicio.centroServicio'+k).value,'KEY_COL','');
	if(cs!='' && cs!= eval('document.centroServicio.centroServicio'+k).value && size!='0'){
		window.opener.document.form0.clearHT.value = 'S';
		window.opener.frames['itemFrame'].doSubmit();
	}
<%
	} else if (fg.equalsIgnoreCase("PAC_U")){//Esto no se esta utilizando porque el centro se selecciona desde la misma pagina con un select.  No borre esto porque hay cosas que quizas se deban tomar en cuenta
%>
	var cds = eval('document.centroServicio.centroServicio'+k).value;
	var estado ='<%=estado%>';
	var categoria ='<%=categoria%>';
	var wh ='';
	var descWh ='';
	var x =0;
	if(cds == '10' || cds == '22' || cds == '117' && (categoria =='2' && estado=='E')){
	wh = '7';
	descWh = 'ALMACEN URGENCIA';
	x++;
	}else if((cds != '10' && cds != '22')  && (categoria == '1' && estado=='A')){
	wh = '1';
	descWh = 'ALMACEN CENTRAL';
	x++;
	}else if((cds == '601' || cds == '607')  && ((categoria =='1' && estado=='A') || (categoria =='2' && estado=='E' ))){
	wh = '8';
	descWh = 'ALMACEN CORONADO';
	x++;
	}
	if(x > 0)
	{
		window.opener.document.requisicion.centroServicio.value = eval('document.centroServicio.centroServicio'+k).value;
		window.opener.document.requisicion.centroServicioDesc.value = eval('document.centroServicio.centroServicioDesc'+k).value;
		window.opener.document.requisicion.tipoCds.value = eval('document.centroServicio.tipoCds'+k).value;
		window.opener.document.requisicion.reportaA.value = eval('document.centroServicio.reportaA'+k).value;
		window.opener.document.requisicion.incremento.value = eval('document.centroServicio.incremento'+k).value;
		window.opener.document.requisicion.tipoInc.value = eval('document.centroServicio.tipo_incremento'+k).value;
		window.opener.document.requisicion.codigo_almacen.value = wh;
		window.opener.document.requisicion.desc_codigo_almacen.value = descWh;

	}else alert('ESTE CENTRO QUE SOLICITA, NO PROCESA CARGOS DE INVENTARIO EN ADMISIONES QUE SEAN DEL TIPO Y ESTADO DE ADMISION SELECCIONADO..');

	<%}else if (fg.equalsIgnoreCase("PAC_S") || fg.equalsIgnoreCase("PAC_D")){%>
		window.opener.document.requisicion.centroServicio.value = eval('document.centroServicio.centroServicio'+k).value;
		window.opener.document.requisicion.centroServicioDesc.value = eval('document.centroServicio.centroServicioDesc'+k).value;
		window.opener.document.requisicion.tipoCds.value = eval('document.centroServicio.tipoCds'+k).value;
		window.opener.document.requisicion.reportaA.value = eval('document.centroServicio.reportaA'+k).value;
		window.opener.document.requisicion.incremento.value = eval('document.centroServicio.incremento'+k).value;
		window.opener.document.requisicion.tipoInc.value = eval('document.centroServicio.tipo_incremento'+k).value;
	<%}else if (fg.equalsIgnoreCase("MAPPING_CPT")){%>
		window.opener.document.form1.cds_code.value = eval('document.centroServicio.centroServicio'+k).value;
		window.opener.document.form1.cds_desc.value = eval('document.centroServicio.centroServicioDesc'+k).value;
		window.opener.document.form1.hasChanged.value = "Y";
	<%}%>
	window.close();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE CENTRO DE SERVICIO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextFilter">
				<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("cs",cs)%>
				<%=fb.hidden("categoria",categoria)%>
				<%=fb.hidden("estado",estado)%>
				<td width="34%">
					<cellbytelabel id="1">C&oacute;digo</cellbytelabel>
					<%=fb.intBox("codigo","",false,false,false,10)%>
					
				</td>
				<td width="33%">
					<cellbytelabel id="2">Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("descripcion","",false,false,false,10)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd(true)%>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td align="right">&nbsp;</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("cs",cs)%>
					<%=fb.hidden("categoria",categoria)%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="3">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="4">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="5">hasta</cellbytelabel> <%=nVal%></td>
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
					<%=fb.hidden("cs",cs)%>
					<%=fb.hidden("categoria",categoria)%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="15%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
					<td width="50%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
					<td width="10%"><cellbytelabel id="6">Tipo Cds.</cellbytelabel></td>
					<td width="15%"><cellbytelabel id="7">Reporta A</cellbytelabel></td>
				</tr>
<%fb = new FormBean("centroServicio",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("cs",cs)%>
<%=fb.hidden("categoria",categoria)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
				<%=fb.hidden("centroServicio"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("centroServicioDesc"+i,cdo.getColValue("descripcion"))%>
				<%=fb.hidden("tipoCds"+i,cdo.getColValue("tipo_cds"))%>
				<%=fb.hidden("reportaA"+i,cdo.getColValue("reporta_a"))%>
				<%=fb.hidden("incremento"+i,cdo.getColValue("incremento"))%>
				<%=fb.hidden("tipo_incremento"+i,cdo.getColValue("tipo_incremento"))%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setTipoAdmision(<%=i%>)" style="cursor:pointer">
					<td align="center"><%=cdo.getColValue("codigo")%></td>
					<td><%=cdo.getColValue("descripcion")%></td>
					<td align="center"><%=cdo.getColValue("tipo_cds")%></td>
					<td align="center"><%=cdo.getColValue("reporta_a")%></td>
				</tr>
<%
}
%>
<%=fb.formEnd()%>
			</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
					<%=fb.hidden("cs",cs)%>
					<%=fb.hidden("categoria",categoria)%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="3">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="4">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="5">hasta</cellbytelabel> <%=nVal%></td>
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
					<%=fb.hidden("cs",cs)%>
					<%=fb.hidden("categoria",categoria)%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
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
<%
}
%>