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
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String cod_banco = request.getParameter("cod_banco");
String cuenta_banco = request.getParameter("cuenta_banco");
String nombre_cuenta = request.getParameter("nombre_cuenta");
if (cod_banco == null) cod_banco = "";
if (cuenta_banco == null) cuenta_banco = "";
if (nombre_cuenta == null) nombre_cuenta = "";

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

	if (!cod_banco.trim().equals("")) { sbFilter.append(" and upper(a.cod_banco) like '%"); sbFilter.append(cod_banco.toUpperCase()); sbFilter.append("%'"); }
	if (!cuenta_banco.trim().equals("")) { sbFilter.append(" and upper(a.cuenta_banco) like '%"); sbFilter.append(cuenta_banco.toUpperCase()); sbFilter.append("%'"); }

	if (request.getParameter("cod_banco") != null) {

		sbSql = new StringBuffer();
		sbSql.append("select * from (select rownum as rn, a.* from (");
			sbSql.append("select '[ ' ||a.cod_banco||' ] '||(select nombre from tbl_con_banco where cod_banco = a.cod_banco and compania = a.compania) as nombre, a.descripcion, a.cod_banco as banco, a.cuenta_banco as cuenta from tbl_con_cuenta_bancaria a where a.compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(sbFilter);
			sbSql.append(" order by a.cod_banco");
		sbSql.append(") a) where rn between ");
		sbSql.append(previousVal);
		sbSql.append(" and ");
		sbSql.append(nextVal);
		al = SQLMgr.getDataList(sbSql);

		sbSql = new StringBuffer();
		sbSql.append("select count(*) from tbl_con_cuenta_bancaria a where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(sbFilter);
		rowCount = CmnMgr.getCount(sbSql.toString());

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
document.title = 'Movimiento Bancario - '+document.title;
function add(){abrir_ventana('../bancos/saldobancario_cuenta_config.jsp');}
function edit(banco,cuenta,nombre){abrir_ventana('../bancos/mov_banco_cheque_list.jsp?mode=edit&banco='+banco+'&cuenta='+cuenta+'&nombre='+encodeURIComponent(nombre));}
function selCuentaBancaria(){var cod_banco=document.search00.cod_banco.value;if(cod_banco=='')alert('Seleccione Banco!');else abrir_ventana('../common/search_cuenta_bancaria.jsp?fp=banco&index=&cod_banco='+cod_banco);}
function printList(){abrir_ventana('../bancos/print_list_movimientobanco.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>');}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="BANCOS - TRANSACCION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td>
		<table width="100%" cellpadding="0" cellspacing="1">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<tr class="TextFilter">
			<td>
				Banco:
<%
sbSql = new StringBuffer();
sbSql.append("select cod_banco, cod_banco||' - '||nombre from tbl_con_banco where compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" order by nombre");
%>
				<%=fb.select(ConMgr.getConnection(),sbSql.toString(),"cod_banco",cod_banco,false,false,0,"Text10","","onChange=\"javascript:setFormFieldsBlank(this.form.name,'cuenta_banco,nombre_cuenta')\"","","T")%>
				Cuenta Bancaria:
				<%=fb.textBox("cuenta_banco",cuenta_banco,false,false,true,15,"Text10",null,"")%>
				<%=fb.textBox("nombre_cuenta",nombre_cuenta,false,false,true,40,"Text10",null,"")%>
				<%=fb.button("buscarCuenta","...",false, false,"Text10","","onClick=\"javascript:selCuentaBancaria()\"")%>
				<%=fb.submit("go","Ir")%>
			</td>
		</tr>
<%=fb.formEnd()%>
		</table>
	</td>
</tr>
<tr>
	<td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
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
<%=fb.hidden("cod_banco",cod_banco)%>
<%=fb.hidden("cuenta_banco",cuenta_banco)%>
<%=fb.hidden("nombre_cuenta",nombre_cuenta)%>
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
<%=fb.hidden("cod_banco",cod_banco)%>
<%=fb.hidden("cuenta_banco",cuenta_banco)%>
<%=fb.hidden("nombre_cuenta",nombre_cuenta)%>
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
		<tr class="TextHeader">
			<td width="5%">&nbsp;</td>
			<td width="40%">Cuenta</td>
			<td width="45%">Descripción</td>
			<td width="10%">&nbsp;</td>
		</tr>
<%
String groupBy = "";
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

	if (!groupBy.equals(cdo.getColValue("banco"))) {
%>
		<tr>
			<td colspan="4">Banco: <%=cdo.getColValue("nombre")%></td>
		</tr>
<% } %>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="right"><%//=preVal + i%>&nbsp;</td>
			<td><%=cdo.getColValue("cuenta")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td align="center">&nbsp;<authtype type='4'><a href="javascript:edit('<%=cdo.getColValue("banco")%>','<%=cdo.getColValue("cuenta")%>','<%=cdo.getColValue("nombre")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Conciliar</a></authtype></td>
		</tr>
<%
	groupBy = cdo.getColValue("banco");
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
<%=fb.hidden("cod_banco",cod_banco)%>
<%=fb.hidden("cuenta_banco",cuenta_banco)%>
<%=fb.hidden("nombre_cuenta",nombre_cuenta)%>
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
<%=fb.hidden("cod_banco",cod_banco)%>
<%=fb.hidden("cuenta_banco",cuenta_banco)%>
<%=fb.hidden("nombre_cuenta",nombre_cuenta)%>
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
<% } %>