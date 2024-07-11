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
String caja = request.getParameter("caja");
String cajera = request.getParameter("cajera");
String fecha_desde = request.getParameter("fecha_desde");
String fecha_hasta = request.getParameter("fecha_hasta");
String cod_cajera = request.getParameter("cod_cajera");
String usuario = request.getParameter("usuario");
if (fp == null) fp = "";
if (caja == null) caja = "";
if (cajera == null) cajera = "";
if (fecha_desde == null) fecha_desde = "";
if (fecha_hasta == null) fecha_hasta = "";
if (cod_cajera == null) cod_cajera = "";
if (usuario==null)usuario="";
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
String validaTurno = "S";
CommonDataObject cdo1 = SQLMgr.getData("select nvl(get_sec_comp_param("+session.getAttribute("_companyId")+",'CJA_VALIDA_ESTADO_TUR'),'S') as validaTurno from dual");
if (cdo1 != null) validaTurno = cdo1.getColValue("validaTurno");

	if (!caja.trim().equals("")) { sbFilter.append(" and a.cod_caja = "); sbFilter.append(caja); }
	if (!cajera.trim().equals("")) { sbFilter.append(" and upper(c.nombre) like '%"); sbFilter.append(cajera.toUpperCase()); sbFilter.append("%'"); }
	if (!fecha_desde.trim().equals("")) { sbFilter.append(" and trunc(b.fecha) >= to_date('"); sbFilter.append(fecha_desde.toUpperCase()); sbFilter.append("', 'dd/mm/yyyy')"); }
	if (!fecha_hasta.trim().equals("")) { sbFilter.append(" and trunc(b.fecha) <= to_date('"); sbFilter.append(fecha_hasta.toUpperCase()); sbFilter.append("', 'dd/mm/yyyy')"); }		    else if(!fecha_desde.trim().equals("")){sbFilter.append(" and trunc(b.fecha) <= to_date('"); sbFilter.append(fecha_desde.toUpperCase()); sbFilter.append("', 'dd/mm/yyyy')"); }
	if (!cod_cajera.trim().equals("")) { sbFilter.append(" and c.cod_cajera = "); sbFilter.append(cod_cajera); }
	if (!usuario.trim().equals("")) { sbFilter.append(" and upper(b.usuario_creacion) = '"); sbFilter.append(usuario.toUpperCase()); sbFilter.append("'"); }
    if(fp.trim().equals("deposito")&&validaTurno.trim().equals("S") ){sbFilter.append(" and a.estatus in('A','T') ");}
	sbSql = new StringBuffer();
	sbSql.append("select * from (select rownum as rn, a.* from (");
		sbSql.append("select a.compania, a.cod_turno, a.cod_caja, b.cja_cajera_cod_cajera cod_cajera, a.estatus, c.nombre nombre_cajera, d.descripcion nombre_caja, to_char(b.hora_inicio, 'hh12:mi am') hora_inicio, to_char(b.fecha, 'dd/mm/yyyy') fecha from tbl_cja_turnos_x_cajas a, tbl_cja_turnos b, tbl_cja_cajera c, tbl_cja_cajas d where a.cod_turno = b.codigo and b.cja_cajera_cod_cajera = c.cod_cajera and a.cod_caja = d.codigo and a.compania = d.compania and a.compania = c.compania and a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(sbFilter);
		sbSql.append(" order by 3, 4");
	sbSql.append(") a) where rn between ");
	sbSql.append(previousVal);
	sbSql.append(" and ");
	sbSql.append(nextVal);
	al = SQLMgr.getDataList(sbSql.toString());

	sbSql = new StringBuffer();
	sbSql.append("select count(*) from tbl_cja_turnos_x_cajas a, tbl_cja_turnos b, tbl_cja_cajera c, tbl_cja_cajas d where a.cod_turno = b.codigo and b.cja_cajera_cod_cajera = c.cod_cajera and a.cod_caja = d.codigo and a.compania = c.compania and a.compania = d.compania and a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(sbFilter);
	rowCount = CmnMgr.getCount(sbSql.toString());

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
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Caja - '+document.title;
function setValues(i){
	<%if(fp!=null && fp.equals("reporte_recibo")){%>
	window.opener.document.form0.caja.value = eval('document.detail.cod_caja'+i).value;
	window.opener.document.form0.turno.value = eval('document.detail.cod_turno'+i).value;
	if(window.opener.document.form0.estatus)window.opener.document.form0.estatus.value=eval('document.detail.estatus'+i).value;
	<%} else if(fp!=null && (fp.equals("informe_ingresos") || fp.equals("ventas_descuento"))){%>
	window.opener.document.search01.turno.value = eval('document.detail.cod_turno'+i).value;
	<%} else if(fp!=null && (fp.equals("farmacia"))){%>
	window.opener.document.form0.turnoTrx.value = eval('document.detail.cod_turno'+i).value;	
	window.opener.document.form0.cajaTrx.value = eval('document.detail.cod_caja'+i).value;
	<%} else if(fp!=null && fp.equals("deposito")){%>
	window.opener.document.form0.turno.value = eval('document.detail.cod_turno'+i).value;
	window.opener.document.form0.name_cajera.value = eval('document.detail.nombre_cajera'+i).value;

	<%} else {%>
	window.opener.document.form0.caja.value = eval('document.detail.cod_caja'+i).value;
	window.opener.document.form0.cajera.value = eval('document.detail.cod_cajera'+i).value;
	window.opener.document.form0.name_cajera.value = eval('document.detail.nombre_cajera'+i).value;
	window.opener.document.form0.turno.value = eval('document.detail.cod_turno'+i).value;
	<%}%>
	window.close();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CAJA - LISTADO DE TURNOS POR CAJA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("cod_cajera",cod_cajera)%>
<%=fb.hidden("usuario",usuario)%>
		<tr class="TextFilter">
			<td>
				<%if(!fp.trim().equals("deposito")){%>
				<cellbytelabel>Caja</cellbytelabel>:
				<%=fb.select(ConMgr.getConnection(),"select codigo, codigo ||' - ' || descripcion descripcion from tbl_cja_cajas where compania = "+(String) session.getAttribute("_companyId")+" order by descripcion asc","caja",caja,false,false,0,null,null,"")%>
				<%}else{%>
				<%=fb.hidden("caja",caja)%>
				<%}%>
				<cellbytelabel>Cajera</cellbytelabel>:
				<%=fb.textBox("cajera",cajera,false,false,false,50,"Text10",null,null)%>
				<cellbytelabel>Fecha</cellbytelabel>:
				<jsp:include page="../common/calendar.jsp" flush="true">
        <jsp:param name="noOfDateTBox" value="2" />
        <jsp:param name="clearOption" value="true" />
        <jsp:param name="nameOfTBox1" value="fecha_desde" />
        <jsp:param name="valueOfTBox1" value="<%=fecha_desde%>" />
        <jsp:param name="nameOfTBox2" value="fecha_hasta" />
        <jsp:param name="valueOfTBox2" value="<%=fecha_hasta%>" />
        </jsp:include>
        <%=fb.submit("ir","Ir")%>
			</td>
		</tr>
<%=fb.formEnd()%>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</td>
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
<%=fb.hidden("caja",caja)%>
<%=fb.hidden("cajera",cajera)%>
<%=fb.hidden("fecha_desde",fecha_desde)%>
<%=fb.hidden("fecha_hasta",fecha_hasta)%>
<%=fb.hidden("cod_cajera",cod_cajera)%>
<%=fb.hidden("usuario",usuario)%>
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
<%=fb.hidden("caja",caja)%>
<%=fb.hidden("cajera",cajera)%>
<%=fb.hidden("fecha_desde",fecha_desde)%>
<%=fb.hidden("fecha_hasta",fecha_hasta)%>
<%=fb.hidden("cod_cajera",cod_cajera)%>
<%=fb.hidden("usuario",usuario)%>
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
		<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="list" exclude="4">
		<tr class="TextHeader" align="center">
			<td width="35%"><cellbytelabel>Caja</cellbytelabel></td>
			<td width="35%"><cellbytelabel>Cajera</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Turno</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Fecha</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Hora Iincio</cellbytelabel></td>
		</tr>
<%fb = new FormBean("detail","");%>
<%=fb.formStart()%>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("cod_caja"+i,cdo.getColValue("cod_caja"))%>
		<%=fb.hidden("cod_cajera"+i,cdo.getColValue("cod_cajera"))%>
		<%=fb.hidden("nombre_cajera"+i,cdo.getColValue("nombre_cajera"))%>
		<%=fb.hidden("cod_turno"+i,cdo.getColValue("cod_turno"))%>
		<%=fb.hidden("estatus"+i,cdo.getColValue("estatus"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer" onClick="javascript:setValues(<%=i%>)">
			<td><%=cdo.getColValue("cod_caja")%>&nbsp;-&nbsp;<%=cdo.getColValue("nombre_caja")%></td>
			<td><%=cdo.getColValue("cod_cajera")%>&nbsp;-&nbsp;<%=cdo.getColValue("nombre_cajera")%></td>
			<td align="center"><%=cdo.getColValue("cod_turno")%></td>
			<td align="center"><%=cdo.getColValue("fecha")%></td>
			<td align="center"><%=cdo.getColValue("hora_inicio")%></td>
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
<%=fb.hidden("caja",caja)%>
<%=fb.hidden("cajera",cajera)%>
<%=fb.hidden("fecha_desde",fecha_desde)%>
<%=fb.hidden("fecha_hasta",fecha_hasta)%>
<%=fb.hidden("cod_cajera",cod_cajera)%>
<%=fb.hidden("usuario",usuario)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
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
<%=fb.hidden("caja",caja)%>
<%=fb.hidden("cajera",cajera)%>
<%=fb.hidden("fecha_desde",fecha_desde)%>
<%=fb.hidden("fecha_hasta",fecha_hasta)%>
<%=fb.hidden("cod_cajera",cod_cajera)%>
<%=fb.hidden("usuario",usuario)%>
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
<%
}
%>