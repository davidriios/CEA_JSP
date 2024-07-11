
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

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";

String estado = request.getParameter("estado");
if(estado==null){
	estado = "R";
	appendFilter += " and a.estado = 'R'";
} else if(!estado.equals("")){
	appendFilter += " and a.estado = '"+estado+"'";
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

	String numero_documento="", anio_recepcion="",fechaDesde="",fechaHasta="",cod_proveedor="",codigo_almacen="";
	if (request.getParameter("numero_documento") != null && !request.getParameter("numero_documento").trim().equals(""))
	{
		appendFilter += " and upper(a.numero_documento) like '%"+request.getParameter("numero_documento").toUpperCase()+"%'";
	    numero_documento = request.getParameter("numero_documento");
	}
	if (request.getParameter("anio_recepcion") != null && !request.getParameter("anio_recepcion").trim().equals(""))
	{
		appendFilter += " and upper(a.anio_recepcion) like '%"+request.getParameter("anio_recepcion").toUpperCase()+"%'";
    	anio_recepcion = request.getParameter("anio_recepcion");
	}
	if (request.getParameter("estado") != null && !request.getParameter("estado").trim().equals(""))
	{
		appendFilter += " and upper(a.estado) like '%"+request.getParameter("estado").toUpperCase()+"%'";
	    estado = request.getParameter("estado");
	}
	if (request.getParameter("fechaDesde") != null && !request.getParameter("fechaDesde").trim().equals(""))
	{
		appendFilter += " and  trunc(a.fecha_documento) >= to_date('"+request.getParameter("fechaDesde")+"','dd/mm/yyyy')";
	    fechaDesde = request.getParameter("fechaDesde");
	}
	if (request.getParameter("fechaHasta") != null && !request.getParameter("fechaHasta").trim().equals(""))
	{
		appendFilter += " and  trunc(a.fecha_documento) <= to_date('"+request.getParameter("fechaHasta")+"','dd/mm/yyyy')";
	    fechaHasta = request.getParameter("fechaHasta");
	}
	if (request.getParameter("codigo_almacen") != null && !request.getParameter("codigo_almacen").trim().equals(""))
	{
		appendFilter += " and  a.codigo_almacen = "+request.getParameter("codigo_almacen");
	    codigo_almacen = request.getParameter("codigo_almacen");
	}
	if (request.getParameter("cod_proveedor") != null && !request.getParameter("cod_proveedor").trim().equals(""))
	{
		appendFilter += " and  a.cod_proveedor = "+request.getParameter("cod_proveedor");
	    cod_proveedor = request.getParameter("cod_proveedor");
	}
	
	sql = "SELECT a.anio_recepcion, a.numero_documento, a.estado, decode(a.estado,'A','ANULADO','R','RECIBIDO') desc_estado, nvl(to_char(a.fecha_documento,'dd/mm/yyyy'), to_char(sysdate,'dd/mm/yyyy')) fecha_documento, a.cod_proveedor, a.codigo_almacen, b.nombre_proveedor, c.descripcion almacen_desc FROM tbl_inv_recepcion_material a, tbl_com_proveedor b, tbl_inv_almacen c where a.cod_proveedor = b.cod_provedor and a.codigo_almacen = c.codigo_almacen and a.compania = c.compania and a.compania = "+session.getAttribute("_companyId") + " and a.fre_documento = 'FG' " + appendFilter+" order by a.fecha_creacion desc";

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);

	rowCount = CmnMgr.getCount("select count(*) count from ("+sql+")");

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
document.title = 'Inventario - '+document.title;

function add()
{
	abrir_ventana('../inventario/reg_recepcion_fact_prov.jsp');
}

function edit(anio_recepcion, id, tp)
{
	abrir_ventana('../inventario/reg_recepcion_fact_prov.jsp?mode=view&id='+id+'&anio='+anio_recepcion);
}

function printList()
{
	abrir_ventana('../inventario/print_list_fact_del_proveedor.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - RECEPCION MAT. Y EQUIPOS A CONSIGNACION - FACT. PROVEEDOR"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">
<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"200071")){
%>
			<authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nueva Recepci&oacute;n ]</a></authtype>
<%
//}
%>
		</td>
  </tr>
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="0" cellspacing="0">

			
			<tr class="TextFilter">
			<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<td width="15%">
					A&ntilde;o
					<%=fb.intBox("anio_recepcion","",false,false,false,10)%>
				</td>
				<td width="15%">
					Solicitud No.
					<%=fb.intBox("numero_documento","",false,false,false,10)%>
				</td>
				<td width="15%">
					Estado
					<%=fb.select("estado","A=Anulado,R=Recibido",estado, false, false, 0, "T")%> 
				</td>
				<td width="15%">
					Cod. Proveedor
					 <%=fb.intBox("cod_proveedor","",false,false,false,10)%> 
				</td>
				<td width="15%">
					Cod. Almacen
					 <%=fb.intBox("codigo_almacen","",false,false,false,10)%> 
				</td>
			</tr>
        	<tr class="TextFilter">
         		<td colspan="5">
          			Fecha 
          			<jsp:include page="../common/calendar.jsp" flush="true">
          			<jsp:param name="noOfDateTBox" value="2" />
          			<jsp:param name="nameOfTBox1" value="fechaDesde" />
          			<jsp:param name="valueOfTBox1" value="" />
          			<jsp:param name="nameOfTBox2" value="fechaHasta" />
          			<jsp:param name="valueOfTBox2" value="" />
          			<jsp:param name="fieldClass" value="Text10" />
          			<jsp:param name="buttonClass" value="Text10" />
          			</jsp:include>
               <%=fb.submit("go","Ir")%> 
			    </td>
				</tr>
			<%=fb.formEnd(true)%>
	
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
  <tr>
    <td align="right">
<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"200070")){
%>
		<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>
<%
//}
%>
			&nbsp;
		</td>
  </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp","","onSubmit=\"javascript:return(replacePercent(this.searchVal))\"");%>
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
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("anio_recepcion",anio_recepcion)%>
				<%=fb.hidden("numero_documento",numero_documento)%>
				<%=fb.hidden("cod_proveedor",cod_proveedor)%>
				<%=fb.hidden("codigo_almacen",codigo_almacen)%>
				<%=fb.hidden("fechaDesde",fechaDesde)%>
				<%=fb.hidden("fechaHasta",fechaHasta)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>  
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%
fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp","","onSubmit=\"javascript:return(replacePercent(this.searchVal))\"");
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
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("anio_recepcion",anio_recepcion)%>
				<%=fb.hidden("numero_documento",numero_documento)%>
				<%=fb.hidden("cod_proveedor",cod_proveedor)%>
				<%=fb.hidden("codigo_almacen",codigo_almacen)%>
				<%=fb.hidden("fechaDesde",fechaDesde)%>
				<%=fb.hidden("fechaHasta",fechaHasta)%>
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
			<td width="8%">A&ntilde;o</td>
			<td width="10%">No. Recepci&oacute;n</td>
			<td width="10%">Fecha Doc.</td>
			<td width="26%">Proveedor</td>
			<td width="28%">Almac&eacute;n</td>
			<td width="8%">Estado</td>
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
			<td align="center"><%=cdo.getColValue("anio_recepcion")%></td>
			<td align="center"><%=cdo.getColValue("numero_documento")%></td>
			<td align="center"><%=cdo.getColValue("fecha_documento")%></td>
			<td align="left">&nbsp;<%=cdo.getColValue("cod_proveedor")+" "+cdo.getColValue("nombre_proveedor")%></td>
			<td align="left">&nbsp;<%=cdo.getColValue("codigo_almacen")+" "+cdo.getColValue("almacen_desc")%></td>
			<td align="center"><%=cdo.getColValue("desc_estado")%></td>
			<td align="center">
<%
//if ((SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"200072"))/* && cdo.getColValue("estado").equals("P")*/){
%>
			<authtype type='1'><a href="javascript:edit(<%=cdo.getColValue("anio_recepcion")%>,<%=cdo.getColValue("numero_documento")%>,'<%=cdo.getColValue("estado")%>')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Ver</a></authtype>
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
<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp","","onSubmit=\"javascript:return(replacePercent(this.searchVal))\"");%>
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
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("anio_recepcion",anio_recepcion)%>
				<%=fb.hidden("numero_documento",numero_documento)%>
				<%=fb.hidden("cod_proveedor",cod_proveedor)%>
				<%=fb.hidden("codigo_almacen",codigo_almacen)%>
				<%=fb.hidden("fechaDesde",fechaDesde)%>
				<%=fb.hidden("fechaHasta",fechaHasta)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp","","onSubmit=\"javascript:return(replacePercent(this.searchVal))\"");%>
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
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("anio_recepcion",anio_recepcion)%>
				<%=fb.hidden("numero_documento",numero_documento)%>
				<%=fb.hidden("cod_proveedor",cod_proveedor)%>
				<%=fb.hidden("codigo_almacen",codigo_almacen)%>
				<%=fb.hidden("fechaDesde",fechaDesde)%>
				<%=fb.hidden("fechaHasta",fechaHasta)%>
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
