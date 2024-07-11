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
String codigo = request.getParameter("codigo");
String name = request.getParameter("name");
String estado =  request.getParameter("estado");
String fp =  request.getParameter("fp");
if (fp == null) fp = "COT";

if (request.getMethod().equalsIgnoreCase("GET")) {
	int recsPerPage=100;
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

	if (codigo == null) codigo = "";
	if (name == null) name = "";
	if (estado == null) estado = "";
	
	sbFilter.append(" where compania = ");
	sbFilter.append((String)session.getAttribute("_companyId"));
	
	if (!codigo.trim().equals("")) { sbFilter.append(" and p.id = "); sbFilter.append(codigo.toUpperCase()); }
    if (!name.trim().equals("")) { sbFilter.append(" and upper(p.nombre) like '%"); sbFilter.append(name.toUpperCase()); sbFilter.append("%'"); }
    if (!estado.trim().equals("")) { sbFilter.append(" and upper(p.estado) ='"); sbFilter.append(estado.toUpperCase()); sbFilter.append("'"); }
	if (!fp.trim().equals("")) { sbFilter.append(" and upper(p.reg_type) ='"); sbFilter.append(fp.toUpperCase()); sbFilter.append("'"); }

	sbSql.append("select p.id, p.nombre, decode(p.estado,'A','ACTIVO','I','INACTIVO','C','CARGOS REALIZADOS') estadoDesc,(select count(*) from tbl_fac_cotizacion_item where id=p.id and estado ='C') as cargado from tbl_fac_cotizacion p");
	sbSql.append(sbFilter);
	sbSql.append(" order by p.id desc ");
	
	if (request.getParameter("beginSearch") != null){
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql.toString()+")");
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
document.title = 'Cotizaciones - '+document.title;
function add(){abrir_ventana('../facturacion/reg_cotizacion.jsp?fp=<%=fp%>');}
function edit(id, status,k){var cargado = eval('document.form0.cargado'+k).value;
var mode= status; if(cargado!='0'&& '<%=fp%>'=='COT')mode='view';
 abrir_ventana('../facturacion/reg_cotizacion.jsp?fp=<%=fp%>&mode='+mode+'&id='+id);}
function printCotizacion(id){abrir_ventana('../facturacion/print_cotizacion.jsp?id='+id);}
function printCotizacionDet(id){abrir_ventana('../facturacion/print_cotizacion_det.jsp?id='+id);}

var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="Admisión - Mantenimiento - Paquete Cargos"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0"  id="_tblMain">

	<tr>
		<td colspan="4" align="right">
			<authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel>Nuevo Registro</cellbytelabel> ]</a></authtype>
		</td>
	</tr>

	<tr class="TextFilter">
		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("beginSearch","")%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("fp",fp)%>
		<td colspan="4">&nbsp;<cellbytelabel id="2">C&oacute;digo</cellbytelabel>&nbsp;
		<%=fb.textBox("codigo",codigo,false,false,false,30,null,null,null)%>
		&nbsp;&nbsp;&nbsp;&nbsp;<cellbytelabel id="3">Nombre</cellbytelabel>&nbsp;&nbsp;
		<%=fb.textBox("name",name,false,false,false,30,null,null,null)%>&nbsp;&nbsp;
		<cellbytelabel>Estado</cellbytelabel>&nbsp;<%=fb.select("estado","A=Activo,I=Inactivo",estado,"T")%>&nbsp;&nbsp;&nbsp;
		<%=fb.submit("go","Ir")%>
		</td>
		<%=fb.formEnd()%>
	</tr>
 	<tr>
		<td align="right">
			<!-- <authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype>-->
		</td>
	</tr>
 	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%
				fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("beginSearch","")%>
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
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("name",name)%>
				<%=fb.hidden("fp",fp)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("beginSearch","")%>
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
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("name",name)%>
					<%=fb.hidden("fp",fp)%>
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
<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("beginSearch","")%>
<%=fb.hidden("curId","")%>
<%=fb.hidden("fp",fp)%>
	<tr class="TextHeader" align="center">
		<td width="10%">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel></td>
		<td width="45%">&nbsp;<cellbytelabel>Nombre</cellbytelabel></td>
		<td width="15%">&nbsp;<cellbytelabel>Estado</cellbytelabel></td>
		<td width="5%">&nbsp;</td>
		<td width="5%">&nbsp;</td>
		<td width="10%">&nbsp;</td>
		<td width="10%">&nbsp;</td>
	</tr>
	<%
		for (int i=0; i<al.size(); i++){
		 CommonDataObject cdo = (CommonDataObject) al.get(i);
		 String color = "TextRow02";
		 if (i % 2 == 0) color = "TextRow01";
		 
		 
	%>
		<%=fb.hidden("cargado"+i,""+cdo.getColValue("cargado"))%>
			<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
				<td align="center">&nbsp;<%=cdo.getColValue("id")%></td>
				<td>&nbsp;<%=cdo.getColValue("nombre")%></td>
				<td align="center">&nbsp;<%=cdo.getColValue("estadoDesc")%></td>
				<td align="center"><%if(cdo.getColValue("cargado").trim().equals("0")||fp.trim().equals("PAQ")){%>
				  <authtype type='4'><a class="Link00Bold" href="javascript:edit(<%=cdo.getColValue("id")%>,'edit',<%=i%>)">Editar</a></authtype><%}%>
				</td>
				<td align="center">
				  <authtype type='1'><a class="Link00Bold" href="javascript:edit(<%=cdo.getColValue("id")%>,'view',<%=i%>)">Ver</a></authtype>
				</td>
				<td align="center">
				  <authtype type='50'><a class="Link00Bold" href="javascript:printCotizacion(<%=cdo.getColValue("id")%>)">IMPRIMIR</a></authtype>
				</td>
				<td align="center">
				  <authtype type='51'><a class="Link00Bold" href="javascript:printCotizacionDet(<%=cdo.getColValue("id")%>)">IMPRIMIR DET</a></authtype>
				</td>
				
			</tr>
	  <%}%>
 <!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
 <%=fb.formEnd(true)%>
   </table>
 </div>
</div>
 	</td>
</tr>
 	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%
				fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("beginSearch","")%>
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
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("name",name)%>
				<%=fb.hidden("fp",fp)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="5">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="6">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="7">hasta</cellbytelabel> <%=nVal%></td>
					<%
					fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("beginSearch","")%>
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
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("name",name)%>
					<%=fb.hidden("fp",fp)%>
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