<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.UserDetail"	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iCdsFlujo" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCdsFlujo" scope="session" class="java.util.Vector" />
<jsp:useBean id="iPaqCds" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vPaqCds" scope="session" class="java.util.Vector" />
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
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String compania = (String) session.getAttribute("_companyId");

int cdsFlujoLastLineNo = 0, paqCdsLastLineNo = 0;

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("cdsFlujoLastLineNo") != null) cdsFlujoLastLineNo = Integer.parseInt(request.getParameter("cdsFlujoLastLineNo"));
if (request.getParameter("paqCdsLastLineNo") != null) paqCdsLastLineNo = Integer.parseInt(request.getParameter("paqCdsLastLineNo"));
if (request.getParameter("mode") == null) mode = "add";

String userName = request.getParameter("userName");
String codigo = request.getParameter("codigo");
String descripcion = request.getParameter("descripcion");
if (userName == null) userName = "";
if (descripcion == null) descripcion = "";
if (codigo == null) codigo = "";

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
	if (!codigo.trim().equals("")) { sbFilter.append(" and c.codigo = ");
		sbFilter.append(codigo);}
	if (!descripcion.trim().equals("")) { sbFilter.append(" and c.descripcion like '%"); sbFilter.append(descripcion.toUpperCase()); sbFilter.append("%'"); }

	sbSql = new StringBuffer();

	if (fp.equalsIgnoreCase("flujo_atencion")) {
		sbSql.append("select * from (select rownum as rn, a.* from (");

		sbSql.append("select c.codigo, c.descripcion, c.tipo_cds, c.reporta_a, nvl(c.incremento,0) incremento, nvl(c.tipo_incremento, ' ') tipo_incremento from tbl_cds_centro_servicio c where c.estado = 'A' and c.compania_unorg = ");
		sbSql.append(compania);

		sbSql.append(sbFilter);
		sbSql.append(") a) where rn between ");
		sbSql.append(previousVal);
		sbSql.append(" and ");
		sbSql.append(nextVal);
	}
	else if (fp.equalsIgnoreCase("paquete_cargos")) {
		sbSql.append("select * from (select rownum as rn, a.* from (");

		sbSql.append("select c.codigo, c.descripcion, c.tipo_cds, c.reporta_a, nvl(c.incremento,0) incremento, nvl(c.tipo_incremento, ' ') tipo_incremento from tbl_cds_centro_servicio c where c.estado = 'A' and c.compania_unorg = ");
		sbSql.append(compania);

		sbSql.append(sbFilter);
		sbSql.append(") a) where rn between ");
		sbSql.append(previousVal);
		sbSql.append(" and ");
		sbSql.append(nextVal);
	}
	al = SQLMgr.getDataList(sbSql);

	rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+") ");

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
document.title = 'Centros - '+document.title;

var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE CENTROS DE SERVICIO"></jsp:param>
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
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("cdsFlujoLastLineNo",""+cdsFlujoLastLineNo)%>
<%=fb.hidden("paqCdsLastLineNo",""+paqCdsLastLineNo)%>
<%=fb.hidden("compania",""+compania)%>
			<td width="50%">
				<cellbytelabel>C&oacute;digo</cellbytelabel>
				<%=fb.textBox("codigo",codigo,false,false,false,40)%>
			</td>
			<td width="50%">
				<cellbytelabel>Descripci&oacute;n</cellbytelabel>
				<%=fb.textBox("descripcion",descripcion,false,false,false,50)%>
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
<%fb = new FormBean("results",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextValP",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousValP",""+(preVal-recsPerPage))%>
<%=fb.hidden("nextValN",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousValN",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("userName",userName)%>
<%=fb.hidden("cdsFlujoLastLineNo",""+cdsFlujoLastLineNo)%>
<%=fb.hidden("paqCdsLastLineNo",""+paqCdsLastLineNo)%>
<%=fb.hidden("compania",""+compania)%>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr class="TextPager">
			<td align="right">
				<% if (!fp.equalsIgnoreCase("cuadro_autorizacion") && !fp.equalsIgnoreCase("user") && !fp.equalsIgnoreCase("cajero")) { %><%=fb.submit("save","Guardar",true,false)%><% } %>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%"><%=(preVal != 1)?fb.submit("previousT","<<-"):""%></td>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
		<table align="center" width="100%" cellpadding="1" cellspacing="1" id="list">
		<tr class="TextHeader" align="center">
			<td width="30%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="60%"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="10%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todos los usuarios listados!")%></td>
		</tr>
<%
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
		<%=fb.hidden("tipo_cds"+i,cdo.getColValue("tipo_cds"))%>
		<%=fb.hidden("reporta_a"+i,cdo.getColValue("reporta_a"))%>
		<%=fb.hidden("incremento"+i,cdo.getColValue("incremento"))%>
		<%=fb.hidden("tipo_incremento"+i,cdo.getColValue("tipo_incremento"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" <%=(fp.equalsIgnoreCase("cuadro_autorizacion") || fp.equalsIgnoreCase("cajero")|| fp.equalsIgnoreCase("user")? "style=\"cursor:pointer\" onClick=\"javascript:setValues("+i+");\"":"")%>>
			<td><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td align="center">
				<%=((fp.equalsIgnoreCase("flujo_atencion") && vCdsFlujo.contains(cdo.getColValue("codigo")+"-"+id)) || (fp.equalsIgnoreCase("paquete_cargos") && vPaqCds.contains(id+"-"+cdo.getColValue("codigo")) ) )?"Elegido":fb.checkbox("check"+i,cdo.getColValue("codigo"),false,false)%>
			</td>
		</tr>
<% } %>
		</table>
</div>
</div>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextB","->>"):""%></td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr class="TextPager">
			<td align="right">
				<% if (!fp.equalsIgnoreCase("cuadro_autorizacion") && !fp.equalsIgnoreCase("user") && !fp.equalsIgnoreCase("cajero")) { %><%=fb.submit("save","Guardar",true,false)%><% } %>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		</table>
	</td>
</tr>
<%=fb.formEnd()%>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
} else {
	int size = Integer.parseInt(request.getParameter("size"));

	for (int i=0; i<size; i++)
	{
		if (request.getParameter("check"+i) != null)
		{
			if (fp.equalsIgnoreCase("flujo_atencion"))
			{
				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("centro_servicio",request.getParameter("codigo"+i));
				cdo.addColValue("centro_servicio_desc",request.getParameter("descripcion"+i));

				cdsFlujoLastLineNo++;

				String key = "";
				if (cdsFlujoLastLineNo < 10) key = "00"+cdsFlujoLastLineNo;
				else if (cdsFlujoLastLineNo < 100) key = "0"+cdsFlujoLastLineNo;
				else key = ""+cdsFlujoLastLineNo;
				cdo.addColValue("key",key);
				cdo.setKey(key);

				try
				{
					iCdsFlujo.put(key, cdo);
					vCdsFlujo.add(cdo.getColValue("codigo")+"-"+id);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
			else if (fp.equalsIgnoreCase("paquete_cargos"))
			{
				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("cds",request.getParameter("codigo"+i));
				cdo.addColValue("centro_servicio_desc",request.getParameter("descripcion"+i));

				paqCdsLastLineNo++;

				String key = "";
				if (paqCdsLastLineNo < 10) key = "00"+paqCdsLastLineNo;
				else if (paqCdsLastLineNo < 100) key = "0"+paqCdsLastLineNo;
				else key = ""+paqCdsLastLineNo;
				cdo.addColValue("key",key);
				cdo.setKey(key);

				try
				{
					iPaqCds.put(key, cdo);
					vPaqCds.add(id+"-"+request.getParameter("codigo"+i));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}// checked
	}

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&cdsFlujoLastLineNo="+cdsFlujoLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&compania="+compania+"&paqCdsLastLineNo="+paqCdsLastLineNo);
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&cdsFlujoLastLineNo="+cdsFlujoLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&compania="+compania+"&paqCdsLastLineNo="+paqCdsLastLineNo);
		return;
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
	 if (fp.equalsIgnoreCase("flujo_atencion"))
	{
%>
	 window.opener.location = '../expediente/exp_flujo_atencion_config.jsp?change=1&tab=2&mode=edit&id=<%=id%>&cdsFlujoLastLineNo=<%=cdsFlujoLastLineNo%>';
<%
	}else if (fp.equalsIgnoreCase("paquete_cargos")){
%>
	window.opener.location = '../admision/paquete_cargo_config.jsp?change=1&tab=4&paqCdsLastLineNo=<%=paqCdsLastLineNo%>&mode=edit&comboId=<%=id%>';
<%
}
%>
	window.close();
}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>
<%
}
%>