<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
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
StringBuilder sbSql = new StringBuilder();
StringBuilder sbFilter = new StringBuilder();
String compania = (String) session.getAttribute("_companyId");

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
	String categoria = request.getParameter("categoria");
	String priceOpt = request.getParameter("priceOpt");
	String priceVal = request.getParameter("priceVal");
	String estado = request.getParameter("estado");
	String costo = request.getParameter("costo");
	String nivel = request.getParameter("nivel");
	if (codigo == null) codigo = "";
	if (nombre == null) nombre = "";
	if (categoria == null) categoria = "";
	if (priceOpt == null) priceOpt = "";
	if (priceVal == null) priceVal = "";
	if (estado == null) estado = "";
	if (costo == null) costo = "";
	if (nivel == null) nivel = "";
	
	if (!codigo.trim().equals("")) { sbFilter.append(" and upper(a.codigo) like '%"); sbFilter.append(codigo.toUpperCase()); sbFilter.append("%'"); }
	if (!nombre.trim().equals("")) { sbFilter.append(" and upper(coalesce(a.observacion,a.descripcion)) like '%");  sbFilter.append(nombre.toUpperCase());  sbFilter.append("%'"); }
	if (!categoria.trim().equals("")) { sbFilter.append(" and a.tipo_categoria = "); sbFilter.append(categoria.toUpperCase()); }
	if (!priceOpt.trim().equals("")) {
		
		if (priceOpt.equalsIgnoreCase("n")) sbFilter.append(" and a.precio is null");
		else if (!priceVal.trim().equals("")) {
		
			sbFilter.append(" and nvl(a.precio,0)");
			if (priceOpt.equals("&lt;")) sbFilter.append("<");
			else if (priceOpt.equals("&gt;")) sbFilter.append(">");
			else sbFilter.append(priceOpt);
			sbFilter.append(priceVal);
		
		}
	
	}
	if (!nivel.equals("")) {
		String _not = " not ";
		if (nivel.equalsIgnoreCase("S")) _not = "";
		sbFilter.append(" and ");
		sbFilter.append(_not);
		sbFilter.append(" exists (select null from tbl_fac_nivel_precio where compania = ");
		sbFilter.append(compania);
		sbFilter.append(" and cargo_servicio = 7 and cargo_code = a.codigo) ");
	}
	if (costo.equalsIgnoreCase("S")) sbFilter.append(" and nvl(a.costo,0) <> 0 ");  
	if (!estado.trim().equals("")) { sbFilter.append(" and upper(a.estado) = '"); sbFilter.append(estado.toUpperCase()); sbFilter.append("'"); }
	if(request.getParameter("estado") != null) {
	
    sbSql.append("SELECT to_char(a.codigo) as codigo, a.descripcion, nvl(a.observacion,' ') as observacion, nvl(b.nombre,'SIN CATEGORIA') as categoria, nvl(a.precio,0) as precio FROM tbl_cds_procedimiento a, tbl_cds_tipo_categoria b WHERE a.tipo_categoria = b.codigo(+)");
		sbSql.append(sbFilter);
		sbSql.append(" order by a.codigo");
    al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) FROM tbl_cds_procedimiento a, tbl_cds_tipo_categoria b WHERE a.tipo_categoria=b.codigo(+)"+sbFilter);
		
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
document.title = 'Procedimientos - '+document.title;
function add(){abrir_ventana('../admision/procedimientos_config.jsp');}
function edit(id){abrir_ventana('../admision/procedimientos_config.jsp?mode=edit&id='+encodeURIComponent(id));}
function printList(p){
	if(p == 0) abrir_ventana('../cellbyteWV/report_container.jsp?reportName=admision/print_list_procedimientos_nivel.rptdesign&appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>&pCtrlHeader=true');
	else abrir_ventana('../admision/print_list_procedimientos.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>');
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}

$(function(){
	$("#categoria").css({width: '100px'})
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CLINICA - ADMISION - MANTENIMIENTOS - PROCEDIMIENTOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain"> 
  <tr>
    <td align="right">
			<authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel id="1">Registrar Nuevo Procedimiento</cellbytelabel> ]</a></authtype>
		</td>
  </tr>
  <tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextFilter">
				<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<td>
					<cellbytelabel id="2">C&oacute;digo</cellbytelabel>
					<%=fb.textBox("codigo",codigo,false,false,false,5)%>
					<cellbytelabel id="3">Nombre</cellbytelabel>
					<%=fb.textBox("nombre",nombre,false,false,false,15)%>
					<cellbytelabel id="4">Categor&iacute;a</cellbytelabel>
					<%=fb.select(ConMgr.getConnection(),"select codigo, nombre, rango from tbl_cds_tipo_categoria order by 2","categoria",categoria,"T")%>
					<cellbytelabel>Precio</cellbytelabel>
					<%=fb.select("priceOpt","=,<,>,n:SIN PRECIO",priceOpt,false,false,false,0,null,null,null,null,"T",null,null,":")%><!---->
					<%=fb.decBox("priceVal",priceVal,false,false,false,5)%>
					<cellbytelabel>Estado</cellbytelabel>
					<%=fb.select("estado","A=ACTIVO,I=INACTIVO",estado,false,false,0,"S")%>
					<cellbytelabel>Costo</cellbytelabel>
					<%=fb.select("costo","N=NO DEFINIDO,S=DEFINIDO",costo,false,false,0,"S")%>
					<cellbytelabel>Nivel</cellbytelabel>
					<%=fb.select("nivel","S=SI,N=NO",nivel,false,false,0,"T")%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
			</tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
  <tr>
    <td align="right">
			<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel id="5">Imprimir Lista</cellbytelabel> ]</a>&nbsp;
			<a href="javascript:printList(0)" class="Link00">[ <cellbytelabel id="5">Imprimir Lista Nivel</cellbytelabel> ]</a>
			</authtype>
		</td>
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
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("categoria",categoria)%>
				<%=fb.hidden("priceOpt",priceOpt)%>
				<%=fb.hidden("priceVal",priceVal)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("costo",costo)%>
				<%=fb.hidden("nivel",nivel)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel id="6">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel id="7">Registros desde</cellbytelabel>  <%=pVal%><cellbytelabel id="8">hasta</cellbytelabel> <%=nVal%></td>
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
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("categoria",categoria)%>
				<%=fb.hidden("priceOpt",priceOpt)%>
				<%=fb.hidden("priceVal",priceVal)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("costo",costo)%>
				<%=fb.hidden("nivel",nivel)%>
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
	<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
			<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="list">
				<tr class="TextHeader" align="center">
				  <td width="4%"><cellbytelabel id="2">C&oacute;digo</cellbytelabel></td>
					<td width="29%"><cellbytelabel id="9">Descripci&oacute;n</cellbytelabel></td>
					<td width="29%"><cellbytelabel id="10">Descripci&oacute;n Español</cellbytelabel></td>
					<td width="29%"><cellbytelabel id="11">Categor&iacute;a</cellbytelabel></td>
					<td width="4%"><cellbytelabel id="12">Precios</cellbytelabel></td>
					<td width="5%">&nbsp;</td>
				</tr>
				<%
				for (int i=0; i<al.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al.get(i);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("codigo")%></td>
					<td class="Text10"><%=cdo.getColValue("descripcion")%></td>
					<td class="Text10"><%=cdo.getColValue("observacion")%></td>
					<td class="Text10"><%=cdo.getColValue("categoria")%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("precio"))%></td>															
					<td align="center">
					<authtype type='4'><a href="javascript:edit('<%=IBIZEscapeChars.forSingleQuots(cdo.getColValue("codigo"))%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel id="13">Editar</cellbytelabel></a></authtype>
					</td>
				</tr>
				<%
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
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("categoria",categoria)%>
				<%=fb.hidden("priceOpt",priceOpt)%>
				<%=fb.hidden("priceVal",priceVal)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("costo",costo)%>
				<%=fb.hidden("nivel",nivel)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel id="6">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel id="7">Registros desde</cellbytelabel> <%=pVal%><cellbytelabel id="8">hasta</cellbytelabel> <%=nVal%></td>
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
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("categoria",categoria)%>
				<%=fb.hidden("priceOpt",priceOpt)%>
				<%=fb.hidden("priceVal",priceVal)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("costo",costo)%>
				<%=fb.hidden("nivel",nivel)%>
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