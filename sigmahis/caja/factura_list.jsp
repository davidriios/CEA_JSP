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
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"100027") || SecMgr.checkAccess(session.getId(),"100028") || SecMgr.checkAccess(session.getId(),"100029") || SecMgr.checkAccess(session.getId(),"100030"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";

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
	
	String codigo  = "";                 // variable para mantener el valor de los campos filtrados en la consulta
  String nombre  = "", estatus = "",fecha="";

	if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
	{
		appendFilter += " and upper(a.codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
		codigo     = request.getParameter("codigo");  // utilizada para mantener el No. de Factura filtrado
	}
	if (request.getParameter("fecha") != null && !request.getParameter("fecha").trim().equals(""))
	{
		appendFilter += " and to_char(a.fecha,'dd/mm/yyyy') = '"+request.getParameter("fecha")+"'";
    fecha = request.getParameter("fecha");
	}
	if (request.getParameter("estatus") != null && !request.getParameter("estatus").trim().equals(""))
	{
		appendFilter += " and upper(a.estatus) like '%"+request.getParameter("estatus").toUpperCase()+"%'";
		estatus    = request.getParameter("estatus");  // utilizada para mantener el estatus de la factura filtrada
	}
	if (request.getParameter("nombre") != null && !request.getParameter("nombre").trim().equals(""))
	{
		appendFilter += " and upper(b.nombre_paciente) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
		nombre     = request.getParameter("nombre");   // utilizada para mantener el nombre del paciente filtrado
	}
	
if (request.getParameter("estatus") != null)
{
	sql = "SELECT a.codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, nvl(a.grang_total,0)monto_total, decode(a.estatus,'P','Pendiente','C','Cancelada','A','Anulada') as estatus, decode(a.facturar_a,'O',a.nombre_cliente,b.nombre_paciente) as paciente, c.nombre as empresa FROM tbl_fac_factura a, vw_adm_paciente b, tbl_adm_empresa c WHERE a.pac_id=b.pac_id(+) and a.cod_empresa=c.codigo(+) and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by b.nombre_paciente asc " ;
	al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");
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
document.title = 'Facturas - '+document.title;

function ver(id)
{
	abrir_ventana('../caja/factura_pagos.jsp?codigo='+id);
}
function printList()
{
	abrir_ventana('../caja/print_list_factura_pagos.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}

function getMain(formx)
{
	formx.status.value = document.search00.status.value;
	return true;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CAJA - CONSULTAS - FACTURA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="1" cellspacing="0">
      <%
fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>

			<tr class="TextFilter">
				<td width="15%">
					<cellbytelabel>Estatus</cellbytelabel>
					<%=fb.select("estatus","P=Pendiente,C=Cancelada,A=Anulada",estatus,"P")%>
				</td>
				<td width="30%">
					<cellbytelabel>Fecha</cellbytelabel>
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="clearOption" value="true" />
					<jsp:param name="nameOfTBox1" value="fecha"/>						
					<jsp:param name="valueOfTBox1" value="<%=fecha%>" />
					</jsp:include>
				</td>
        <td width="15%">
					<cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.textBox("codigo",codigo,false,false,false,10)%>
				</td>
        <td width="40%">
				 <cellbytelabel>Nombre</cellbytelabel>
					<%=fb.textBox("nombre",nombre,false,false,false,30)%>
					<%=fb.submit("go","Ir")%>
				</td>
        
			</tr>
			<%=fb.formEnd()%>
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
  <tr>
    <td align="right">&nbsp;
			<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype>
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
        <%=fb.hidden("estatus",""+estatus)%>
        <%=fb.hidden("fecha",""+fecha)%>
        <%=fb.hidden("codigo",""+codigo)%>
        <%=fb.hidden("nombre",""+nombre)%>
        
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
        <%=fb.hidden("estatus",""+estatus)%>
        <%=fb.hidden("fecha",""+fecha)%>
        <%=fb.hidden("codigo",""+codigo)%>
        <%=fb.hidden("nombre",""+nombre)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
<table width="99%" cellpadding="0" cellspacing="0" align="center">
	<tr>
		<td class="TableLeftBorder TableRightBorder">
		
	<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="list">
	<tr class="TextHeader" align="center">
	    <td width="7%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
		<td width="30%"><cellbytelabel>Paciente/Cliente</cellbytelabel></td>
		<td width="28%"><cellbytelabel>Empresa</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Fecha</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Monto Total</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Estatus</cellbytelabel></td>
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
			<td><%=cdo.getColValue("paciente")%></td>
			<td><%=cdo.getColValue("empresa")%></td>
			<td><%=cdo.getColValue("fecha")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_total"))%>&nbsp;&nbsp;</td>
			<td><%=cdo.getColValue("estatus")%></td>
			<td><a href="javascript:ver('<%=cdo.getColValue("codigo")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Ver</cellbytelabel></a></td>
		</tr>
<%
}
%>				
</table>
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
        <%=fb.hidden("estatus",""+estatus)%>
        <%=fb.hidden("fecha",""+fecha)%>
        <%=fb.hidden("codigo",""+codigo)%>
        <%=fb.hidden("nombre",""+nombre)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
        <%=fb.hidden("estatus",""+estatus)%>
        <%=fb.hidden("fecha",""+fecha)%>
        <%=fb.hidden("codigo",""+codigo)%>
        <%=fb.hidden("nombre",""+nombre)%>
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