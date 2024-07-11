<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
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
String empresa = java.util.ResourceBundle.getBundle("planmedico").getString("empresa");
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;
//String empresa = request.getParameter("empresa");
String status = request.getParameter("status");
StringBuffer sql = new StringBuffer();
StringBuffer appendFilter = new StringBuffer();
String secuencia="",nombre="";

if (empresa == null) empresa = "";
if (!empresa.equalsIgnoreCase("")){
	appendFilter.append(" and a.empresa=");
	appendFilter.append(empresa);
}
if (status == null) status = "";
if (!status.equalsIgnoreCase("")){
	appendFilter.append(" and a.estatus='");
	appendFilter.append(status);
	appendFilter.append("'");
}
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

	if (request.getParameter("secuencia") != null && !request.getParameter("secuencia").trim().equals(""))
	{
		appendFilter.append(" and upper(a.secuencia) like '%");
		appendFilter.append(request.getParameter("secuencia").toUpperCase());
		appendFilter.append("%'");
		secuencia = request.getParameter("secuencia");
	}
	if (request.getParameter("nombre") != null && !request.getParameter("nombre").trim().equals(""))
	{
		appendFilter.append(" and upper(a.nombre) like '%");
		appendFilter.append(request.getParameter("nombre").toUpperCase());
		appendFilter.append("%'");
		nombre = request.getParameter("nombre");
	}
	if (!UserDet.getUserProfile().contains("0"))appendFilter.append(" and b.codigo > 0 ");

//
	sql.append("select a.empresa, a.secuencia, a.nombre, a.contacto, to_char(a.fecha_inicial,'dd/mm/yyyy') as fechaInicial, nvl(to_char(a.fecha_final,'dd/mm/yyyy'),'---') as fechaFinal, a.estatus, b.nombre as empresaNombre from tbl_adm_convenio a, tbl_adm_empresa b where a.empresa=b.codigo and a.tipo_convenio='C'");
	sql.append(appendFilter.toString());
	sql.append(" order by b.nombre, a.secuencia desc");

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from ("+sql.toString()+")");

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
document.title = 'Transacciones - Registro de Convenios - '+document.title;
function add(){abrir_ventana('../planmedico/pm_convenio_config.jsp');}
function edit(empresa, secuencia){abrir_ventana('../planmedico/pm_convenio_config.jsp?mode=edit&empresa='+empresa+'&secuencia='+secuencia);}
function printList(){abrir_ventana('print_pm_list_convenio.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter.toString())%>');}
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="TRANSACCIONES - REGISTRO DE CONVENIOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right">&nbsp;<authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel>Registrar Nuevo Convenio</cellbytelabel> ]</a></authtype></td>
</tr>
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<td colspan="2">
				<cellbytelabel>Empresa</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select codigo, nombre, codigo from tbl_adm_empresa where tipo_empresa in (1,2,3,5) and codigo > 0 order by nombre","empresa",empresa,"T")%>
				<cellbytelabel>Estado</cellbytelabel>
				<%=fb.select("status","A=ACTIVA,I=INACTIVO",status,"T")%>
			</td>
		</tr>
		<tr class="TextFilter">
			<td width="50%">
				<cellbytelabel>No. Convenio</cellbytelabel>
				<%=fb.intBox("secuencia","",false,false,false,30)%>
			</td>
			<td width="50%">
				<cellbytelabel>Nombre</cellbytelabel>
				<%=fb.textBox("nombre","",false,false,false,30)%>
				<%=fb.submit("go","Ir")%>
			</td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td align="right">&nbsp;<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype></td>
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
<%=fb.hidden("empresa",empresa).replaceAll(" id=\"empresa\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("secuencia",""+secuencia)%>
<%=fb.hidden("nombre",""+nombre)%>
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
<%=fb.hidden("empresa",empresa).replaceAll(" id=\"empresa\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("secuencia",""+secuencia)%>
<%=fb.hidden("nombre",""+nombre)%>
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
			<td width="3%"><cellbytelabel>C&oacute;d</cellbytelabel>.</td>
			<td width="24%"><cellbytelabel>Empresa</cellbytelabel></td>
			<td width="3%"><cellbytelabel>No</cellbytelabel>.</td>
			<td width="25%"><cellbytelabel>Convenio</cellbytelabel></td>
			<td width="18%"><cellbytelabel>Contacto</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Fecha Inicial</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Fecha Final</cellbytelabel></td>
			<td width="6%"><cellbytelabel>Estado</cellbytelabel></td>
			<td width="5%">&nbsp;</td>
		</tr>
<%
String empresaNombre = "";
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("empresa")%></td>
			<td><%=cdo.getColValue("empresaNombre")%></td>
			<td align="center"><%=cdo.getColValue("secuencia")%></td>
			<td><%=cdo.getColValue("nombre")%></td>
			<td><%=cdo.getColValue("contacto")%></td>
			<td align="center"><%=cdo.getColValue("fechaInicial")%></td>
			<td align="center"><%=cdo.getColValue("fechaFinal")%></td>
			<td align="center"><cellbytelabel><%=(cdo.getColValue("estatus").equalsIgnoreCase("A"))?"ACTIVO":"INACTIVO"%></cellbytelabel></td>
			<td align="center">&nbsp;<authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("empresa")%>,<%=cdo.getColValue("secuencia")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Editar</cellbytelabel></a></authtype></td>
		</tr>
<%
	empresaNombre = "["+cdo.getColValue("empresa")+"] "+cdo.getColValue("empresaNombre");
}
%>
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
<%=fb.hidden("empresa",empresa).replaceAll(" id=\"empresa\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("secuencia",""+secuencia)%>
<%=fb.hidden("nombre",""+nombre)%>
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
<%=fb.hidden("empresa",empresa).replaceAll(" id=\"empresa\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("secuencia",""+secuencia)%>
<%=fb.hidden("nombre",""+nombre)%>
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