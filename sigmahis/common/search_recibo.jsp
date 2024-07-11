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
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fp = request.getParameter("fp");
String tipoCliente = request.getParameter("tipoCliente");
String refId = request.getParameter("refId");
String turno = request.getParameter("turno");
String idx = request.getParameter("idx");

if (fp == null) fp = "";
if (tipoCliente == null) tipoCliente = "";
if (refId == null) refId = "";
if (fp.trim().equals("")) throw new Exception("La Pantalla Origen no está definida (fp). Por favor consulte con su Administrador!");
else if (fp.equalsIgnoreCase("recibos")) { sbFilter.append(" and a.rec_status = 'I' and nvl(a.anulacion_sup,'x') <> 'S' and a.turno <> a.turno_anulacion and a.turno_anulacion = "); sbFilter.append(turno); sbFilter.append(" and not exists ( select null from tbl_cja_trans_forma_pagos b,tbl_cja_transaccion_pago p where no_referencia = a.recibo and fp_codigo = 0 and p.codigo  = b.tran_codigo and p.compania = b.compania and p.anio = b.tran_anio and p.rec_status <> 'I' )");}
if (tipoCliente.trim().equals("")) throw new Exception("El Tipo de Recibo no es válido. Por favor intente nuevamente!");
/*
if (refId.trim().equals("")) sbFilter.append(" and a.ref_id is null");
else { sbFilter.append(" and a.ref_id = "); sbFilter.append(refId); }
if (tipoCliente.equalsIgnoreCase("A")) { sbFilter.append(" and a.tipo_cliente = 'O' and a.cliente_alq = 'S'"); }
else if (tipoCliente.equalsIgnoreCase("O")) { sbFilter.append(" and a.tipo_cliente = 'O' and nvl(a.cliente_alq,'N') = 'N'"); }
else { sbFilter.append(" and a.tipo_cliente = '"); sbFilter.append(tipoCliente.toUpperCase()); sbFilter.append("'"); }
*/
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

	String recibo = request.getParameter("recibo");
	String nombre = request.getParameter("nombre");
	String nombreAdicional = request.getParameter("nombreAdicional");
	String fecha = request.getParameter("fecha");
	if (recibo == null) recibo = "";
	if (nombre == null) nombre = "";
	if (nombreAdicional == null) nombreAdicional = "";
	if (fecha == null) fecha = "";
	if (!recibo.trim().equals("")) { sbFilter.append(" and upper(a.recibo) like '%"); sbFilter.append(recibo.toUpperCase()); sbFilter.append("%'"); }
	if (!nombre.trim().equals("")) { sbFilter.append(" and upper(a.nombre) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
	if (!nombreAdicional.trim().equals("")) { sbFilter.append(" and upper(a.nombre_adicional) like '%"); sbFilter.append(nombreAdicional.toUpperCase()); sbFilter.append("%'"); }
	if (!fecha.trim().equals("")) { sbFilter.append(" and a.fecha = to_date('"); sbFilter.append(fecha); sbFilter.append("','dd/mm/yyyy')"); }

	sbSql.append("select a.compania, a.codigo, a.recibo, a.anio, a.tipo_cliente, a.codigo_paciente, a.pago_total, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.descripcion, a.nombre, a.nombre_adicional");
	sbSql.append(" from tbl_cja_transaccion_pago a,tbl_cja_trans_forma_pagos fp");
	sbSql.append(" where a.compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and a.codigo  = fp.tran_codigo and a.compania = fp.compania and a.anio = fp.tran_anio and fp.fp_codigo <> 0 ");
	sbSql.append(sbFilter);
	sbSql.append(" order by a.anio desc, a.codigo desc");
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from tbl_cja_transaccion_pago a where a.compania = "+(String) session.getAttribute("_companyId")+sbFilter);

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
document.title = 'LISTADO DE RECIBOS - '+document.title;
function setRecibo(k){<% if (fp.equalsIgnoreCase("recibos")) { %>if(parent.window.frames['formaPago'].document.formFP.noReferencia<%=idx%>)parent.window.frames['formaPago'].document.formFP.noReferencia<%=idx%>.value=eval('document.result.recibo'+k).value;if(parent.window.frames['formaPago'].document.formFP.monto<%=idx%>)parent.window.frames['formaPago'].document.formFP.monto<%=idx%>.value=eval('document.result.pago_total'+k).value;if(parent.window.frames['formaPago'].calcTotal)parent.window.frames['formaPago'].calcTotal();parent.hidePopWin(true);<% } %>}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CAJA - LISTADO DE RECIBOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;<a href="javascript:parent.window.frames['formaPago'].resetFormaPago('');parent.hidePopWin(true);" class="Link05Bold">[ Cerrar ]</a></td>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("tipoCliente",tipoCliente)%>
<%=fb.hidden("refId",refId)%>
<%=fb.hidden("turno",turno)%>
<%=fb.hidden("idx",idx)%>
			<td width="20%">
				Recibo<br>
				<%=fb.textBox("recibo",recibo,false,false,false,12,"Text10",null,null)%>
			</td>
			<td width="30%">
				Cliente<br>
				<%=fb.textBox("nombre",nombre,false,false,false,30,"Text10",null,null)%>
			</td>
			<td width="30%">
				Nombre Adicional<br>
				<%=fb.textBox("nombreAdicional",nombreAdicional,false,false,false,30,"Text10",null,null)%>
			</td>
			<td width="20%">
				Fecha<br>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="fecha" />
				<jsp:param name="valueOfTBox1" value="<%=fecha%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				</jsp:include>
				<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
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
<%=fb.hidden("tipoCliente",tipoCliente)%>
<%=fb.hidden("refId",refId)%>
<%=fb.hidden("turno",turno)%>
<%=fb.hidden("idx",idx)%>
<%=fb.hidden("recibo",recibo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("nombreAdicional",nombreAdicional)%>
<%=fb.hidden("fecha",fecha)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
<%=fb.hidden("tipoCliente",tipoCliente)%>
<%=fb.hidden("turno",turno)%>
<%=fb.hidden("idx",idx)%>
<%=fb.hidden("recibo",recibo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("nombreAdicional",nombreAdicional)%>
<%=fb.hidden("fecha",fecha)%>
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
		<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="list" exclude="7,8">
		<tr class="TextHeader" align="center">
			<td width="20%">Recibo</td>
			<td width="30%">Cliente</td>
			<td width="30%">Nombre Adicional</td>
			<td width="10%">Fecha</td>
			<td width="10%">Pago Total</td>
		</tr>
<% if (al.size() == 0) { %>
		<tr>
			<td colspan="5" class="TextRow01" align="center"><font color="#FF0000">R E G I S T R O ( S ) &nbsp; N O &nbsp; E N C O N T R A D O ( S )</font></td>
		</tr>
<% } %>
<%fb = new FormBean("result","","");%>
<%=fb.formStart()%>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
		<%=fb.hidden("anio"+i,cdo.getColValue("anio"))%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("recibo"+i,cdo.getColValue("recibo"))%>
		<%=fb.hidden("pago_total"+i,cdo.getColValue("pago_total"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setRecibo(<%=i%>);" style="text-decoration:none; cursor:pointer">
			<td align="center"><%=cdo.getColValue("recibo")%></td>
			<td><%=cdo.getColValue("nombre")%></td>
			<td><%=cdo.getColValue("nombre_adicional")%></td>
			<td align="center"><%=cdo.getColValue("fecha")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("pago_total"))%></td>
		</tr>
<%
}
%>
<%=fb.formEnd()%>
		</table>
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
<%=fb.hidden("tipoCliente",tipoCliente)%>
<%=fb.hidden("refId",refId)%>
<%=fb.hidden("turno",turno)%>
<%=fb.hidden("idx",idx)%>
<%=fb.hidden("recibo",recibo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("nombreAdicional",nombreAdicional)%>
<%=fb.hidden("fecha",fecha)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
<%=fb.hidden("tipoCliente",tipoCliente)%>
<%=fb.hidden("turno",turno)%>
<%=fb.hidden("idx",idx)%>
<%=fb.hidden("recibo",recibo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("nombreAdicional",nombreAdicional)%>
<%=fb.hidden("fecha",fecha)%>
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