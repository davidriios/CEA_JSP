
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
==========================================================================================
200069	VER LISTA DE ORDEN DE COMPRA NORMAL
200070	IMPRIMIR LISTA DE ORDEN DE COMPRA NORMAL
200071	AGREGAR SOLICITUD DE ORDEN DE COMPRA NORMAL
200072	MODIFICAR SOLICITUD DE ORDEN DE COMPRA NORMAL
==========================================================================================
**/
SecMgr.setConnection(ConMgr);

if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
/*
if (
!( SecMgr.checkAccess(session.getId(),"0") 
	|| ((SecMgr.checkAccess(session.getId(),"200069") || SecMgr.checkAccess(session.getId(),"200070") || SecMgr.checkAccess(session.getId(),"200071") || SecMgr.checkAccess(session.getId(),"200072"))) )
	) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
*/
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

/*
*/

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fgFilter = "";
String fg = request.getParameter("fg");
String familia = request.getParameter("cod_familia");
String clase = request.getParameter("cod_clase");
String articulo = request.getParameter("cod_familia");
String wh = request.getParameter("wh");
String fechaIni = request.getParameter("fechaIni");
String fechaFin = request.getParameter("fechaFin");
String descArticulo = request.getParameter("descArticulo");


if(fg==null) fg = "";

if(familia ==null) familia ="";
if(clase ==null) clase ="";
if(articulo ==null) articulo ="";
if(wh ==null) wh ="";
if(fechaIni ==null) fechaIni ="";
if(fechaFin ==null) fechaFin ="";
if(descArticulo ==null) descArticulo ="";

if(!familia.trim().equals(""))	appendFilter += " and a.cod_familia like '%"+familia+"%'";
if(!clase.trim().equals("")) 	appendFilter += " and a.cod_clase like '%"+clase+"%'";
if(!articulo.trim().equals("")) appendFilter += " and a.cod_articulo like '%"+articulo+"%'";
if(!wh.trim().equals("")) 		appendFilter += " and a.almacen = "+wh;

if(!fechaIni.trim().equals("")) appendFilter += " and to_date(to_char(a.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date('"+fechaIni+"','dd/mm/yyyy')";
if(!fechaFin.trim().equals("")) appendFilter += " and to_date(to_char(a.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+fechaFin+"','dd/mm/yyyy')";
if(!descArticulo.trim().equals(""))appendFilter += " and b.descripcion like '%"+descArticulo+"%'";



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

	
	if(!appendFilter.trim().equals(""))
	{

	sql = "select a.secuencia, a.compania, a.almacen, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.cod_familia, a.cod_clase, a.cod_articulo, a.cantidad, b.descripcion articulo from tbl_inv_coversion_encab a, tbl_inv_articulo b where a.cod_articulo = b.cod_articulo and a.compania =  "+(String) session.getAttribute("_companyId") +" "+ appendFilter+" order by to_date(to_char(a.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') desc  ";
	
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);

	rowCount = CmnMgr.getCount("select count(*) count from ("+sql+")");
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
document.title = 'Inventario - '+document.title;

function add()
{
	abrir_ventana('../inventario/reg_conv.jsp?mode=add&fg=<%=fg%>');
}

function edit(id, almacen)
{
	abrir_ventana('../inventario/reg_conv.jsp?mode=view&id='+id+'&almacen='+almacen);
}

function printList()
{
	<%	if(!appendFilter.trim().equals("")){%>
	abrir_ventana('../inventario/print_list_conversion_art.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>&fg=<%=fg%>');
	<%}%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>

<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - REGISTRO DE KIT / BANDEJA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">
<authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Conversi&oacute;n ]</a></authtype>
		</td>
  </tr>
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextFilter">
		
<%
fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fg",fg)%>
				<td colspan="2">
					Almacen 
					<%=fb.select("wh","","")%>
      <script language="javascript">
			loadXML('../xml/almacenes.xml','wh','<%=wh%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>','KEY_COL','S');
			</script>
					
				</td>
				<td>
					<jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="2" />
							<jsp:param name="clearOption" value="true" />
							<jsp:param name="nameOfTBox1" value="fechaIni" />
							<jsp:param name="valueOfTBox1" value="<%=fechaIni%>" />
							<jsp:param name="nameOfTBox2" value="fechaFin" />
							<jsp:param name="valueOfTBox2" value="<%=fechaFin%>" />
							</jsp:include>
				</td>
			</tr>
			<tr class="TextFilter">
				<td width="20%">
					
					Familia
					<%=fb.intBox("cod_familia","",false,false,false,10)%>
					
				</td>
				<td width="20%">
					Clase
					<%=fb.intBox("cod_clase","",false,false,false,10)%>
				</td>
				<td width="60%">
					Articulo
					<%=fb.intBox("cod_articulo","",false,false,false,10)%>
					<%=fb.intBox("descArticulo","",false,false,false,30)%>
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

			<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>
			&nbsp;
		</td>
  </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
<%
fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
%>
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
				<%=fb.hidden("familia",familia)%>
				<%=fb.hidden("clase",clase)%>
				<%=fb.hidden("articulo",articulo)%>
				<%=fb.hidden("wh",wh)%>
				<%=fb.hidden("descArticulo",descArticulo)%>
				<%=fb.hidden("fechaIni",fechaIni)%>
				<%=fb.hidden("fechaFin",fechaFin)%>
				
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
				<%=fb.hidden("familia",familia)%>
				<%=fb.hidden("clase",clase)%>
				<%=fb.hidden("articulo",articulo)%>
				<%=fb.hidden("wh",wh)%>
				<%=fb.hidden("descArticulo",descArticulo)%>
				<%=fb.hidden("fechaIni",fechaIni)%>
				<%=fb.hidden("fechaFin",fechaFin)%>
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
			<td width="5%">&nbsp;</td>
			<td width="10%">Fecha</td>
			<td width="10%">Familia</td>
			<td width="10%">Clase</td>
			<td width="10%">Articulo</td>
			<td width="40%" align="left">Descripcion</td>
			<td width="10%">Cantidad</td>
			<td width="10%">&nbsp;</td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="right"><%=preVal + i%>&nbsp;</td>
			<td align="center"><%=cdo.getColValue("fecha")%></td>
			<td align="center"><%=cdo.getColValue("cod_familia")%></td>
			<td align="center"><%=cdo.getColValue("cod_clase")%></td>
			<td align="center"><%=cdo.getColValue("cod_articulo")%></td>
			<td><%=cdo.getColValue("articulo")%></td>
			<td align="center"><%=cdo.getColValue("cantidad")%></td>
			<td align="center">
<authtype type='1'> <a href="javascript:edit(<%=cdo.getColValue("secuencia")%>,<%=cdo.getColValue("almacen")%>)" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Ver</a></authtype>
<%
//}
%>
			</td>
		</tr>
<%
}
%>
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
<%
fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
%>
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
				<%=fb.hidden("familia",familia)%>
				<%=fb.hidden("clase",clase)%>
				<%=fb.hidden("articulo",articulo)%>
				<%=fb.hidden("wh",wh)%>
				<%=fb.hidden("descArticulo",descArticulo)%>
				<%=fb.hidden("fechaIni",fechaIni)%>
				<%=fb.hidden("fechaFin",fechaFin)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%
fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
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
				<%=fb.hidden("familia",familia)%>
				<%=fb.hidden("clase",clase)%>
				<%=fb.hidden("articulo",articulo)%>
				<%=fb.hidden("wh",wh)%>
				<%=fb.hidden("descArticulo",descArticulo)%>
				<%=fb.hidden("fechaIni",fechaIni)%>
				<%=fb.hidden("fechaFin",fechaFin)%>
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
