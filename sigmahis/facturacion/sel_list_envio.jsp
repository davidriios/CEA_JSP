<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
============================================================================
===========================================================================
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
String fEnvio = request.getParameter("fEnvio");
String facturado_a = request.getParameter("facturado_a");
String categoria = request.getParameter("categoria");
String empresa = request.getParameter("empresa");
String fechaDesde = request.getParameter("fechaDesde");
String fechaHasta = request.getParameter("fechaHasta");
String aseguradoraDesc = request.getParameter("aseguradoraDesc");
if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if(aseguradoraDesc==null)aseguradoraDesc="";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage = 100;
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

	String codigo = request.getParameter("codigo");
	String nombre = request.getParameter("nombre");
	String appendTable = "";
		
	
		if (fEnvio != null && !fEnvio.trim().equals(""))appendFilter += " and trunc(a.fecha) = to_date('"+fEnvio+"','dd/mm/yyyy')";
		if (fechaDesde != null && !fechaDesde.trim().equals(""))appendFilter += " and trunc(a.fecha) >= to_date('"+fechaDesde+"','dd/mm/yyyy')";
		if (fechaHasta != null && !fechaHasta.trim().equals(""))appendFilter += " and trunc(a.fecha) <= to_date('"+fechaHasta+"','dd/mm/yyyy')";
		if (facturado_a != null && !facturado_a.trim().equals("")) appendFilter += " and a.facturar_a  = '"+facturado_a+"'" ;
		if (categoria != null && !categoria.trim().equals("")) appendFilter += " and b.categoria  = "+categoria ;
		if (empresa != null && !empresa.trim().equals("")) appendFilter += " and a.cod_empresa  = "+empresa ;
		else aseguradoraDesc="";
		if (codigo != null && !codigo.trim().equals("")) appendFilter += " and a.lista  = "+codigo;
	
	if(!UserDet.getUserProfile().contains("0")) appendFilter += " and  a.usuario_creacion= '"+(String) session.getAttribute("_userName")+"'";
	
if(request.getParameter("codigo") != null){
	sql="select distinct a.lista,(select comentario from  tbl_fac_lista where compania    =a.compania and trunc(fecha_envio) = trunc(a.fecha) and aseguradora = a.cod_empresa and categoria = b.categoria and lista =  a.lista and facturar_a = a.facturar_a and usuario_creacion =a.usuario_creacion)  comentario,to_char(a.fecha,'dd/mm/yyyy') fecha,a.cod_empresa,a.facturar_a,b.categoria,decode( a.facturar_a,'E','EMPRESA','P','PACIENTE','OTROS') facturarDesc ,(select nombre from tbl_adm_empresa where codigo =a.cod_empresa)descEmpresa ,(select descripcion from tbl_adm_categoria_admision where codigo =b.categoria ) descCategoria,a.fecha fechaFact  from tbl_fac_factura a, tbl_adm_admision b where   a.compania = "+(String) session.getAttribute("_companyId")+" and a.estatus <> 'A' and a.pac_id = b.pac_id and a.admi_secuencia = b.secuencia "+appendFilter+" order by a.fecha desc,1 asc ";
	
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
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
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Listas - '+document.title;

function setLista(k)
{
	window.opener.document.form1.lista.value = eval('document.listado.lista'+k).value;
	window.opener.document.form1.fecha_envio.value = eval('document.listado.fecha'+k).value;
	window.opener.document.form1.facturas_a.value = eval('document.listado.facturar_a'+k).value;
	window.opener.document.form1.aseguradora.value = eval('document.listado.cod_empresa'+k).value;
	window.opener.document.form1.aseguradoraDesc.value = eval('document.listado.aseguradoraDesc'+k).value;
	window.opener.document.form1.categoria.value = eval('document.listado.categoria'+k).value;
	if(window.opener.document.form1.comentario)window.opener.document.form1.comentario.value = eval('document.listado.comentario'+k).value;
	window.close();
}

function showEmpresaList(){abrir_ventana1('../common/search_empresa.jsp?fp=sel_list_aseg');}
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE EMPRESA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="0" cellspacing="0">
		<tr class="TextFilter">
<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
			<td width="50%">
				<cellbytelabel>Lista</cellbytelabel>
				<%=fb.textBox("codigo",codigo,false,false,false,10,"Text10",null,"")%>
				<jsp:include page="../common/calendar.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="2" />
                <jsp:param name="clearOption" value="true" />
                <jsp:param name="nameOfTBox1" value="fechaDesde" />
                <jsp:param name="valueOfTBox1" value="<%=fechaDesde%>" />
                <jsp:param name="nameOfTBox2" value="fechaHasta" />
                <jsp:param name="valueOfTBox2" value="<%=fechaHasta%>" />
                <jsp:param name="fieldClass" value="text10" />
                <jsp:param name="buttonClass" value="text10" />
              </jsp:include>
			  <cellbytelabel>Categor&iacute;a</cellbytelabel>:<%=fb.select(ConMgr.getConnection(),"select codigo, codigo||'-'||descripcion descripcion from tbl_adm_categoria_admision order by codigo","categoria",categoria,false,false,0,"Text10",null,"","","")%>
			  <cellbytelabel>Facturas a</cellbytelabel>:
			  <%=fb.select("facturado_a","E=Empresa,P=Paciente",facturado_a,false,false,0,"Text10",null,"","","S")%> 
			 <cellbytelabel>C&iacute;a. de Seguros</cellbytelabel>: 
			<%=fb.intBox("empresa",empresa,false,false,false,5,"Text10",null,"")%> 
			<%=fb.textBox("aseguradoraDesc",aseguradoraDesc,false,false,true,25,"Text10",null,null)%> 
			<%=fb.button("btnAseg","...",true,false,"Text10",null,"onClick=\"javascript:showEmpresaList()\"")%>
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
<%=fb.hidden("empresa",empresa)%>
<%=fb.hidden("facturado_a",facturado_a)%>
<%=fb.hidden("categoria",categoria)%>
<%=fb.hidden("fechaDesde",fechaDesde)%>
<%=fb.hidden("fechaHasta",fechaHasta)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("aseguradoraDesc",aseguradoraDesc)%>
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
<%=fb.hidden("empresa",empresa)%>
<%=fb.hidden("facturado_a",facturado_a)%>
<%=fb.hidden("categoria",categoria)%>
<%=fb.hidden("fechaDesde",fechaDesde)%>
<%=fb.hidden("fechaHasta",fechaHasta)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("aseguradoraDesc",aseguradoraDesc)%>
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
<%fb = new FormBean("listado",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
		<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="list">
		<tr class="TextHeader" align="center">
			<td width="5%">No. Lista</td>
			<td width="10%">Fecha</td>
			<td width="20%">Facturas A</td>
			<td width="20%">Categoria</td>
			<td width="40%">Empresa</td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
<%=fb.hidden("lista"+i,cdo.getColValue("lista"))%>
<%=fb.hidden("comentario"+i,cdo.getColValue("comentario"))%>
<%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
<%=fb.hidden("facturar_a"+i,cdo.getColValue("facturar_a"))%>
<%=fb.hidden("cod_empresa"+i,cdo.getColValue("cod_empresa"))%>
<%=fb.hidden("categoria"+i,cdo.getColValue("categoria"))%>
<%=fb.hidden("aseguradoraDesc"+i,cdo.getColValue("descEmpresa"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setLista(<%=i%>)" style="cursor:pointer">
			<td><%=cdo.getColValue("lista")%></td>
			<td><%=cdo.getColValue("fecha")%></td>
			<td><%=cdo.getColValue("facturarDesc")%></td>
			<td><%=cdo.getColValue("descCategoria")%></td>
			<td>[<%=cdo.getColValue("cod_empresa")%>] - <%=cdo.getColValue("descEmpresa")%></td>
		</tr>
<%
}
%>
		</table>
<%=fb.formEnd()%>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("empresa",empresa)%>
<%=fb.hidden("facturado_a",facturado_a)%>
<%=fb.hidden("categoria",categoria)%>
<%=fb.hidden("fechaDesde",fechaDesde)%>
<%=fb.hidden("fechaHasta",fechaHasta)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("aseguradoraDesc",aseguradoraDesc)%>
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
<%=fb.hidden("empresa",empresa)%>
<%=fb.hidden("facturado_a",facturado_a)%>
<%=fb.hidden("categoria",categoria)%>
<%=fb.hidden("fechaDesde",fechaDesde)%>
<%=fb.hidden("fechaHasta",fechaHasta)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("aseguradoraDesc",aseguradoraDesc)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}
%>