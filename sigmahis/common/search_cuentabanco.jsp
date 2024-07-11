<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
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
StringBuffer sbSql = new StringBuffer();
StringBuffer sbField = new StringBuffer();
StringBuffer sbTable = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fp = request.getParameter("fp");
String index = request.getParameter("index");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (index == null) index = "";

String codigo = request.getParameter("codigo");
String nombre = request.getParameter("nombre");
if (codigo == null) codigo = "";
if (nombre == null) nombre = "";

if (request.getMethod().equalsIgnoreCase("GET")) {
	int recsPerPage = 100;
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

	if (fp.equalsIgnoreCase("cierreBanco")) {
		sbField.append(", b.anio, b.mes, to_char(to_date('01/'||nvl(b.mes,12)||'/'||to_char(sysdate,'yyyy'),'dd/mm/yyyy'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') as mesDesc");
		sbTable.append(", tbl_con_sb_saldos b");
		sbFilter.append(" and a.compania = b.compania and a.cuenta_banco = b.cuenta_banco and b.estatus = 'A'");
	}
	if (!codigo.trim().equals("")) { sbFilter.append(" and upper(a.cod_banco) like '%"); sbFilter.append(codigo.toUpperCase()); sbFilter.append("%'"); }
	if (!nombre.trim().equals("")) { sbFilter.append(" and exists (select null from tbl_con_banco where cod_banco = a.cod_banco and compania = a.compania and upper(nombre) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%')"); }
	
	
	if (fp.equalsIgnoreCase("cierre")) {
		sbField.append(", (select max(cpto_anio) from tbl_con_detalle_cuenta where compania=a.compania and cod_banco=a.cod_banco and cuenta_banco=a.cuenta_banco ) anioCierre ,to_char((select max(fecha_mes) from tbl_con_detalle_cuenta where compania=a.compania and cod_banco=a.cod_banco and cuenta_banco=a.cuenta_banco and cpto_anio  = (select max(cpto_anio) from tbl_con_detalle_cuenta where compania=a.compania and cod_banco=a.cod_banco and cuenta_banco=a.cuenta_banco )),'00') mesCierre,(select to_char(to_date('01/'||nvl(max(fecha_mes) ,01)||'/'||to_char(sysdate,'yyyy'),'dd/mm/yyyy'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') from tbl_con_detalle_cuenta where compania=a.compania and cod_banco=a.cod_banco and cuenta_banco=a.cuenta_banco and cpto_anio  = (select max(cpto_anio) from tbl_con_detalle_cuenta where compania=a.compania and cod_banco=a.cod_banco and cuenta_banco=a.cuenta_banco ))mesCierreDesc ");
		//sbTable.append(", tbl_con_detalle_cuenta b");
		sbFilter.append(" and a.estado_cuenta = 'ACT' ");
	}

	sbSql = new StringBuffer();
	sbSql.append("select x.* ");
	if (fp.equalsIgnoreCase("cierre")) {sbSql.append(",(select estatus from tbl_con_estado_meses where cod_cia= x.compania and ano=x.aniocierre and mes=x.mescierre) statusCierre ");}
	
	sbSql.append(" from (select rownum as rn, a.* from (");
		sbSql.append("select (select nombre from tbl_con_banco where cod_banco = a.cod_banco and compania = a.compania)||' '||a.descripcion as nombre, a.cod_banco as banco, a.cuenta_banco as cuenta,a.compania ");
		sbSql.append(sbField);
		sbSql.append(" from tbl_con_cuenta_bancaria a");
		sbSql.append(sbTable);
		sbSql.append(" where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(sbFilter);
		sbSql.append(" order by a.cod_banco");
	sbSql.append(") a)x where rn between ");
	sbSql.append(previousVal);
	sbSql.append(" and ");
	sbSql.append(nextVal);

	al = SQLMgr.getDataList(sbSql);

	sbSql = new StringBuffer("select count(*) from tbl_con_cuenta_bancaria a");
	sbSql.append(sbTable);
	sbSql.append(" where a.compania = ");
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
<script language="javascript">
document.title = 'Cuentas Bancarias - '+document.title;
function setResult(k){
<% if (fp.equalsIgnoreCase("cierre")) { %>
	window.opener.document.form0.banco.value = eval('document.result.banco'+k).value;
	window.opener.document.form0.nombre.value = eval('document.result.nombre'+k).value;
	window.opener.document.form0.cuenta.value = eval('document.result.cuenta'+k).value;
	window.opener.document.form0.anio.value = eval('document.result.anioCierre'+k).value;
	window.opener.document.form0.mes.value = eval('document.result.mesCierre'+k).value;
	window.opener.document.form0.estadoMes.value = eval('document.result.statusCierre'+k).value;
	if(eval('document.result.anioCierre'+k).value!='')window.opener.document.form0.ultMesProc.value ='ULTIMO MES CERRADO:  '+eval('document.result.anioCierre'+k).value+"   -   "+eval('document.result.mesCierreDesc'+k).value;
	else window.opener.document.form0.ultMesProc.value ='NO EXISTE CIERRE DE CONCILIACION PARA LA CUENTA SELECCIONADA';
	window.opener.document.form0.revertir.disabled = true;
	if(eval('document.result.statusCierre'+k).value!='CER'){window.opener.document.form0.revertir.disabled = false;}else{window.opener.document.form0.revertir.disabled = true;}
	
<% } else if (fp.equalsIgnoreCase("cierreBanco")) { %>
	window.opener.document.form0.banco.value = eval('document.result.bancoB'+k).value;
	window.opener.document.form0.nombre.value = eval('document.result.nombreB'+k).value;
	window.opener.document.form0.cuenta.value = eval('document.result.cuentaB'+k).value;
	window.opener.document.form0.anio.value = eval('document.result.anio'+k).value;
	window.opener.document.form0.anioDesc.value = eval('document.result.anio'+k).value;
	window.opener.document.form0.mes.value = eval('document.result.mes'+k).value;
	window.opener.document.form0.mesDesc.value = eval('document.result.mesDesc'+k).value;
<% } %>
	window.close();
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();} 
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE CUENTAS BANCARIAS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td>
		<table width="100%" cellpadding="0" cellspacing="0">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
		<tr class="TextFilter">
			<td width="50%">
				<cellbytelabel>C&oacute;digo</cellbytelabel>
				<%=fb.textBox("codigo",codigo,false,false,false,40)%>
			</td>
			<td width="50%">
				<cellbytelabel>Nombre</cellbytelabel>
				<%=fb.textBox("nombre",nombre,false,false,false,40)%>
				<%=fb.submit("go","Ir")%>
			</td>
		</tr>
<%=fb.formEnd()%>
		</table>
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
<tr>
	<td class="TableLeftBorder TableRightBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
<%fb = new FormBean("result",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
<% if (fp.equalsIgnoreCase("cierreBanco")) { %>
		<tr class="TextHeader" align="center">
			<td width="15%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="35%"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="25%"><cellbytelabel>Cuenta Bancaria</cellbytelabel></td>
			<td width="10%"><cellbytelabel>A&ntilde;o</cellbytelabel></td>
			<td width="15%"><cellbytelabel>Mes</cellbytelabel></td>
		</tr>
<% } else { %>
		<tr class="TextHeader" align="center">
			<td width="15%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="55%"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="30%"><cellbytelabel>Cuenta Bancaria</cellbytelabel></td>
		</tr>
<% } %>
<%
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	if (fp.equalsIgnoreCase("cierreBanco")) {
%>
		<%=fb.hidden("cuentaB"+i,cdo.getColValue("cuenta"))%>
		<%=fb.hidden("nombreB"+i,cdo.getColValue("nombre"))%>
		<%=fb.hidden("bancoB"+i,cdo.getColValue("banco"))%>
		<%=fb.hidden("anio"+i,cdo.getColValue("anio"))%>
		<%=fb.hidden("mes"+i,cdo.getColValue("mes"))%>
		<%=fb.hidden("mesDesc"+i,cdo.getColValue("mesDesc"))%>
		<%=fb.hidden("statusCierre"+i,cdo.getColValue("statusCierre"))%>
		
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setResult(<%=i%>)" style="text-decoration:none; cursor:pointer">
			<td><%=cdo.getColValue("banco")%></td>
			<td><%=cdo.getColValue("nombre")%></td>
			<td><%=cdo.getColValue("cuenta")%></td>
			<td><%=cdo.getColValue("anio")%></td>
			<td><%=cdo.getColValue("mesDesc")%></td>
		</tr>
<% } else { %>
		<%=fb.hidden("cuenta"+i,cdo.getColValue("cuenta"))%>
		<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
		<%=fb.hidden("banco"+i,cdo.getColValue("banco"))%>
		<%=fb.hidden("mesCierre"+i,cdo.getColValue("mesCierre"))%>
		<%=fb.hidden("anioCierre"+i,cdo.getColValue("anioCierre"))%>
		<%=fb.hidden("mesCierreDesc"+i,cdo.getColValue("mesCierreDesc"))%>		
		<%=fb.hidden("statusCierre"+i,cdo.getColValue("statusCierre"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setResult(<%=i%>)" style="text-decoration:none; cursor:pointer">
			<td><%=cdo.getColValue("banco")%></td>
			<td><%=cdo.getColValue("nombre")%></td>
			<td><%=cdo.getColValue("cuenta")%> - <%=cdo.getColValue("statusCierre")%></td>
		</tr>
<% } %>
<% } %>
<%=fb.formEnd()%>
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
<% } %>