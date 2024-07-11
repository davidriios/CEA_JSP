<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Hashtable"%>
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
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");
String cuenta_banco = request.getParameter("cuenta_banco");
String nombre_cuenta = request.getParameter("nombre_cuenta");
String nombre_banco = request.getParameter("nombre_banco");
String estado = request.getParameter("estado");
if (cod_banco == null) cod_banco = "";
if (tDate == null) tDate = "";
if (fDate == null) fDate = "";
if (cuenta_banco == null) cuenta_banco = "";
if (nombre_cuenta == null) nombre_cuenta = "";
if (nombre_banco == null) nombre_banco = "";
if (estado == null) estado = "";
if (estado.trim().equals("")) estado = "T";

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

	if (!cod_banco.trim().equals("")) { sbFilter.append(" and upper(a.banco) like '%"); sbFilter.append(cod_banco.toUpperCase()); sbFilter.append("%'"); }
	if (!tDate.trim().equals("") && !fDate.trim().equals("")) { sbFilter.append(" and trunc(a.f_movimiento) >= to_date('"); sbFilter.append(tDate); sbFilter.append("','dd/mm/yyyy')"); sbFilter.append(" and trunc(a.f_movimiento) <= to_date('"); sbFilter.append(fDate); sbFilter.append("','dd/mm/yyyy')"); } else if (!tDate.trim().equals("")) { sbFilter.append(" and trunc(a.f_movimiento) = to_date('"); sbFilter.append(tDate); sbFilter.append("','dd/mm/yyyy')"); }
	if (!cuenta_banco.trim().equals("")) { sbFilter.append(" and upper(a.cuenta_banco) like '%"); sbFilter.append(cuenta_banco.toUpperCase()); sbFilter.append("%'"); }
	if (!estado.trim().equals("")) { sbFilter.append(" and a.estado_trans = '"); sbFilter.append(estado.toUpperCase()); sbFilter.append("'"); }

	if (request.getParameter("cod_banco") != null) {
		sbSql = new StringBuffer();
		sbSql.append("select * from (select rownum as rn, a.* from (");
			sbSql.append("select a.consecutivo_ag as consecutivo, a.tipo_movimiento as tipocode, a.cuenta_banco as cuentacode, a.banco as bancocode, to_char(a.f_movimiento,'dd/mm/yyyy') as fecha, to_char(a.fecha_pago,'dd/mm/yyyy') as fechapago, a.estado_dep, a.lado, decode(a.tipo_movimiento,'1',decode(a.estado_dep,'DN','DEPOSITADO','DT','EN TRANSITO'), decode(a.estado_trans,'T','TRAMITADA','C','CONCILIADA','A','ANULADA')) as estado, a.num_documento as doc, a.estado_trans, a.monto, nvl((select descripcion from tbl_con_tipo_movimiento where cod_transac = a.tipo_movimiento),' ') as tipo, nvl((select descripcion from tbl_con_cuenta_bancaria where cuenta_banco = a.cuenta_banco and cod_banco = a.banco and compania = a.compania),' ') as cuenta, nvl((select nombre from tbl_con_banco where cod_banco = a.banco and compania = a.compania),' ') as banco from tbl_con_movim_bancario a where a.compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(sbFilter);
			sbSql.append(" order by 4, 14, a.f_movimiento, 2");
		sbSql.append(") a) where rn between ");
		sbSql.append(previousVal);
		sbSql.append(" and ");
		sbSql.append(nextVal);
		al = SQLMgr.getDataList(sbSql);

		sbSql = new StringBuffer();
		sbSql.append("select count(*) from tbl_con_movim_bancario a where a.compania = ");
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
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Movimiento Bancario - '+document.title;
function add(){abrir_ventana('../contabilidad/movimientobancario_config.jsp');}
function edit(tipo,cuenta,banco,fecha,consecutivo,estado){if(estado=="T"){abrir_ventana('../contabilidad/movimientobancario_config.jsp?mode=edit&tipo_mov='+tipo+'&cuenta='+cuenta+'&banco='+banco+'&fecha='+fecha+'&consecutivo='+consecutivo);}else{abrir_ventana('../contabilidad/movimientobancario_config.jsp?mode=ver&tipo_mov='+tipo+'&cuenta='+cuenta+'&banco='+banco+'&fecha='+fecha+'&consecutivo='+consecutivo);}}
function selCuentaBancaria(){var cod_banco=document.search00.cod_banco.value;if(cod_banco=='')alert('Seleccione Banco!');else abrir_ventana('../common/search_cuenta_bancaria.jsp?fp=banco&cod_banco='+cod_banco);}
function printList(){abrir_ventana('../contabilidad/print_list_mov_bancario.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>');}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right"><authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nuevo Movimiento Bancario ]</a></authtype></td>
</tr>
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<tr class="TextFilter">
			<td>Tipo Doc:
					<%//=fb.select(ConMgr.getConnection(),"select cod_transac, cod_transac||' - '||descripcion from tbl_con_tipo_movimiento order by cod_transac","docType",docType,false,false,0, "text10", "", "", "", "T")%>
            			<%=fb.select("docType","1=DEPOSITO,2=N/DEBITO,3=N/CREDITO",docType, false, false,0,"text10",null,"","","T")%>
				Banco
<%
sbSql = new StringBuffer();
sbSql.append("select cod_banco, cod_banco||' - '||nombre from tbl_con_banco where compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" order by nombre");
%>
				<%=fb.select(ConMgr.getConnection(),sbSql.toString(),"cod_banco",cod_banco,false,false,0,"Text10","","onChange=\"javascript:setFormFieldsBlank(this.form.name,'cuenta_banco,nombre_cuenta')\"","","T")%>
				Fecha
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2"/>
				<jsp:param name="nameOfTBox1" value="tDate"/>
				<jsp:param name="valueOfTBox1" value="<%=tDate%>"/>
				<jsp:param name="nameOfTBox2" value="fDate"/>
				<jsp:param name="valueOfTBox2" value="<%=fDate%>"/>
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
				<jsp:param name="clearOption" value="true"/>
				</jsp:include>
			</td>
		</tr>
		<tr class="TextFilter">
			<td>
				Cta.:
				<%=fb.textBox("cuenta_banco",cuenta_banco,false,false,true,15,"Text10",null,"")%>
				<%=fb.textBox("nombre_cuenta",nombre_cuenta,false,false,true,30,"Text10",null,"")%>
				<%=fb.button("buscarCuenta","...",false, false,"Text10","","onClick=\"javascript:selCuentaBancaria()\"")%>
				Estado:
				<%=fb.select("estado","T=Tramitada,C=Conciliada,A=Anulada",estado)%>
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
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("cuenta_banco",cuenta_banco)%>
<%=fb.hidden("nombre_banco",nombre_banco)%>
<%=fb.hidden("estado",estado)%>
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
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("cuenta_banco",cuenta_banco)%>
<%=fb.hidden("nombre_banco",nombre_banco)%>
<%=fb.hidden("estado",estado)%>
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
		<tr class="TextHeader" align="center">
			<td width="15%">Tipo</td>
			<td width="20%">Banco</td>
			<td width="15%">Cuenta</td>
			<td width="10%">Documento</td>
			<td width="10%">Fecha</td>
			<td width="10%">Estado</td>
			<td width="10%">Monto</td>
			<td width="10%">&nbsp;</td>
		</tr>
<%
String bank="";
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	if (!bank.equalsIgnoreCase(cdo.getColValue("bancoCode"))) {
%>
		<tr class="TextRow03" onMouseOver="setoverc(this,'TextRow03')" onMouseOut="setoutc(this,'TextRow03')">
			<td colspan="6">Banco: [ <%=cdo.getColValue("bancoCode")%> ] <%=cdo.getColValue("banco")%>  Cta: <%=cdo.getColValue("cuenta")%></td>
			<td colspan="2" align="center">&nbsp;</td>
		</tr>
<% } %>
		<%=fb.hidden("estado",cdo.getColValue("estado"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("tipo")%></td>
			<td><%=cdo.getColValue("banco")%></td>
			<td><%=cdo.getColValue("cuenta")%></td>
			<td><%=cdo.getColValue("doc")%></td>
			<td align="center"><%=cdo.getColValue("fecha")%></td>
			<td align="center"><%=cdo.getColValue("estado")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%></td>
			<td align="center"><authtype type='4'><a href="javascript:edit('<%=cdo.getColValue("tipoCode")%>','<%=cdo.getColValue("cuentaCode")%>','<%=cdo.getColValue("bancoCode")%>','<%=cdo.getColValue("fecha")%>',<%=cdo.getColValue("consecutivo")%>,'<%=cdo.getColValue("estado_trans")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></authtype></td>
		</tr>
<%
	bank = cdo.getColValue("bancoCode");
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
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("cuenta_banco",cuenta_banco)%>
<%=fb.hidden("nombre_banco",nombre_banco)%>
<%=fb.hidden("estado",estado)%>
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
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("cuenta_banco",cuenta_banco)%>
<%=fb.hidden("nombre_banco",nombre_banco)%>
<%=fb.hidden("estado",estado)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<% } %>
