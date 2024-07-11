<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
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

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");
String index = request.getParameter("index");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (index == null) index = "";

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

	String codigo = request.getParameter("codigo");
	String nombre = request.getParameter("nombre");
	if (codigo == null) codigo = "";
	if (nombre == null) nombre = "";
	if (!codigo.trim().equals("")) appendFilter += " and upper(cod_provedor) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
	if (!nombre.trim().equals("")) appendFilter += " and upper(nombre_proveedor) like '%"+IBIZEscapeChars.forSingleQuots(request.getParameter("nombre").toUpperCase())+"%'";
	if (fp.equalsIgnoreCase("presInv")||fp.equalsIgnoreCase("csop")) appendFilter += " and estado_proveedor = 'ACT' ";

	if ((fp.equalsIgnoreCase("asiento") || fp.equalsIgnoreCase("consulta_recepcion") || fp.equalsIgnoreCase("ajuste") || fp.equalsIgnoreCase("activo")||fp.equalsIgnoreCase("presInv")|| fp.equalsIgnoreCase("morosidad")|| fp.equalsIgnoreCase("pago_otro")||fp.equalsIgnoreCase("comprob")||fp.equalsIgnoreCase("csop") ) && request.getParameter("codigo")!= null)
	{
		if(!fp.equalsIgnoreCase("consulta_recepcion"))appendFilter+=" and vetado='N'  ";
		sql = "select cod_provedor, nombre_proveedor,ruc,digito_verificador as dv, tipo_persona from tbl_com_proveedor where compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by nombre_proveedor";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from("+sql+")");
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
document.title = 'Proveedor - '+document.title;
function setResult(k)
{
<%
if (fp.equalsIgnoreCase("asiento"))
{
%>
		window.opener.document.form1.refId<%=index%>.value = eval('document.result.codigo'+k).value;
		window.opener.document.form1.refDesc<%=index%>.value = eval('document.result.nombre'+k).value;
<%
}
else if (fp.equalsIgnoreCase("consulta_recepcion"))
{
%>
		window.opener.document.main.provCode.value = eval('document.result.codigo'+k).value;
		window.opener.document.main.provName.value = eval('document.result.nombre'+k).value;
<%
}
else if (fp.equalsIgnoreCase("ajuste"))
{
%>
		window.opener.document.form1.ref_id.value = eval('document.result.codigo'+k).value;
		window.opener.document.form1.nombre.value = eval('document.result.nombre'+k).value;
<%
} else if (fp.equalsIgnoreCase("activo"))
{
%>
		if(window.opener.document.form1.cod_provee)window.opener.document.form1.cod_provee.value = eval('document.result.codigo'+k).value;
		else if(window.opener.document.form0.cod_provee)window.opener.document.form0.cod_provee.value = eval('document.result.codigo'+k).value;
		if(window.opener.document.form1.proveedor_desc)window.opener.document.form1.proveedor_desc.value = eval('document.result.nombre'+k).value;
		else if(window.opener.document.form0.proveedor_desc)window.opener.document.form0.proveedor_desc.value = eval('document.result.nombre'+k).value;
		
<%
} else if (fp.equalsIgnoreCase("presInv"))
{
%>
		window.opener.document.form1.codigoProveedor.value = eval('document.result.codigo'+k).value;
		window.opener.document.form1.descProveedor.value = eval('document.result.nombre'+k).value;
<%
}
 else if (fp.equalsIgnoreCase("morosidad"))
{
%>
		window.opener.document.form0.proveedor.value = eval('document.result.codigo'+k).value;
		window.opener.document.form0.proveedorDesc.value = eval('document.result.nombre'+k).value;
<%
}
 else if (fp.equalsIgnoreCase("pago_otro"))
{
%>
		window.opener.document.form1.medicoRefId.value = eval('document.result.codigo'+k).value;
		window.opener.document.form1.medicoRefNombre.value = eval('document.result.nombre'+k).value;
<%
}else if (fp.equalsIgnoreCase("comprob"))
{
%>
		window.opener.document.form1.ref_id<%=index%>.value = eval('document.result.codigo'+k).value;
		window.opener.document.form1.nombre<%=index%>.value = eval('document.result.nombre'+k).value;
<%}else if (fp.equalsIgnoreCase("csop"))
{
%>
		window.opener.document.form0.ref_id<%=index%>.value = eval('document.result.codigo'+k).value;
		window.opener.document.form0.nombre<%=index%>.value = eval('document.result.nombre'+k).value;
		window.opener.document.form0.ruc<%=index%>.value = eval('document.result.ruc'+k).value;
		window.opener.document.form0.dv<%=index%>.value = eval('document.result.dv'+k).value;
		window.opener.document.form0.tipoPersona<%=index%>.value = eval('document.result.tipoPersona'+k).value;
<%
}
%>

		window.close();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE PROVEEDOR"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
			<td width="34%">
				<cellbytelabel>C&oacute;digo</cellbytelabel>
				<%=fb.intBox("codigo","",false,false,false,10)%>
			</td>
			<td width="33%">
				<cellbytelabel>Nombre</cellbytelabel>
				<%=fb.textBox("nombre",(fp.equalsIgnoreCase("csop"))?nombre:"",false,false,false,50)%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
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

		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="25%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="75%"><cellbytelabel>Nombre</cellbytelabel></td>
		</tr>
<%fb = new FormBean("result",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("cod_provedor"))%>
		<%=fb.hidden("nombre"+i,cdo.getColValue("nombre_proveedor"))%>
		<%=fb.hidden("ruc"+i,cdo.getColValue("ruc"))%>
		<%=fb.hidden("dv"+i,cdo.getColValue("dv"))%>
		<%=fb.hidden("tipoPersona"+i,cdo.getColValue("tipoPersona"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setResult(<%=i%>)" style="cursor:pointer">
			<td align="center"><%=cdo.getColValue("cod_provedor")%></td>
			<td><%=cdo.getColValue("nombre_proveedor")%></td>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
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
