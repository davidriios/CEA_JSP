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
=========================================================================
=========================================================================
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
String num_cheque = request.getParameter("num_cheque");
String fecha_desde = request.getParameter("fecha_desde");
String fecha_hasta = request.getParameter("fecha_hasta");
String tipo = request.getParameter("tipo");
String odp = request.getParameter("odp");
String factura = request.getParameter("factura");
String fg = request.getParameter("fg");
String tipoOrden = request.getParameter("tipoOrden");
String pagosA = request.getParameter("pagosA");
String beneficiario = request.getParameter("beneficiario");

if(cod_banco==null) cod_banco = "";
if(cuenta_banco==null) cuenta_banco = "";
if(nombre_cuenta==null) nombre_cuenta = "";
if(num_cheque==null) num_cheque = "";
if(fecha_desde == null) fecha_desde = "";
if(fecha_hasta == null) fecha_hasta = "";
if(tipo == null) tipo = "N";
if(odp == null) odp = "";
if(factura == null) factura = "";
if(fg == null) fg = "PROV";
if(tipoOrden == null)if(fg.trim().equals("HON"))tipoOrden = "1";else tipoOrden = "";
if(pagosA == null) pagosA = "";
if(beneficiario == null) beneficiario = "";

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

	if (!cod_banco.trim().equals("")) { sbFilter.append(" and upper(a.cod_banco) = '"); sbFilter.append(cod_banco.toUpperCase()); sbFilter.append("'"); }
	if (!cuenta_banco.trim().equals("")) { sbFilter.append(" and upper(a.cuenta_banco) = '"); sbFilter.append(cuenta_banco.toUpperCase()); sbFilter.append("'"); }
	if (!num_cheque.trim().equals("")) { sbFilter.append(" and upper(a.num_cheque) like '%"); sbFilter.append(num_cheque.toUpperCase()); sbFilter.append("%'"); }
	if (!fecha_desde.trim().equals("")) { sbFilter.append(" and trunc(a.f_emision) >= to_date('"); sbFilter.append(fecha_desde); sbFilter.append("','dd/mm/yyyy')"); }
	if (!fecha_hasta.trim().equals("")) { sbFilter.append(" and trunc(a.f_emision) <= to_date('"); sbFilter.append(fecha_hasta); sbFilter.append("','dd/mm/yyyy')"); }
	if (!factura.trim().equals("")) { sbFilter.append(" and e.numero_factura like '"); sbFilter.append(factura.toUpperCase()); sbFilter.append("%'"); }
	if (!odp.trim().equals("")) { sbFilter.append(" and odp.num_orden_pago = "); sbFilter.append(odp); }
	if (!tipoOrden.trim().equals("")) { sbFilter.append(" and odp.cod_tipo_orden_pago = "); sbFilter.append(tipoOrden); }
	if (!pagosA.trim().equals("")) { sbFilter.append(" and odp.tipo_orden = '"); sbFilter.append(pagosA.toUpperCase()); sbFilter.append("'"); }
	if (!beneficiario.trim().equals("")) { sbFilter.append(" and a.beneficiario like '%"); sbFilter.append(beneficiario.toUpperCase()); sbFilter.append("%'"); }

	sbSql.append("select distinct a.cod_compania, a.cod_banco, a.cuenta_banco, a.num_cheque, a.beneficiario, a.monto_girado, to_char(a.f_emision,'dd/mm/yyyy') as f_emision, a.estado_cheque, decode(a.estado_cheque,'G','Girado') as estado_desc, a.anio, a.num_orden_pago");
	sbSql.append(", (select nombre from tbl_con_banco where compania = a.cod_compania and cod_banco = a.cod_banco) as nombre_banco");
	sbSql.append(", (select descripcion from tbl_con_cuenta_bancaria where cod_banco = a.cod_banco and compania = a.cod_compania and cuenta_banco = a.cuenta_banco) as nombre_cuenta");
	if (!fg.equalsIgnoreCase("HON")) sbSql.append(", (case when d.monto != a.monto_girado or nvl(e.numero_factura,'0') in ('0','00') then 'F' when d.monto = a.monto_girado and e.numero_factura not in ('0','00') then 'V' else 'N' end) as tipo");
	else sbSql.append(", (case when d.monto != a.monto_girado or d.num_fact in ('0','00') then 'F' when d.monto = a.monto_girado and d.num_fact not in ('0','00') then 'V' else 'N' end) as tipo");
	sbSql.append(", decode(odp.cod_medico,null,decode(odp.cod_empresa,null,' ','E'),'M') as tipoBenef, odp.num_id_beneficiario, odp.cod_tipo_orden_pago");
	sbSql.append(", nvl(f.monto, 0) monto_facturas from tbl_con_cheque a, (select cod_compania, anio, num_orden_pago, sum(monto + nvl(itbm,0)) as monto");
	if (fg.equalsIgnoreCase("HON")) sbSql.append(", nvl(numero_factura,'0') as num_fact");
	sbSql.append(" from tbl_cxp_orden_de_pago_fact where tipo_docto = 'FAC' group by cod_compania, anio, num_orden_pago");
	if (fg.equalsIgnoreCase("HON")) sbSql.append(", nvl(numero_factura,'0')");
	sbSql.append(") d, (select cod_compania, anio, num_orden_pago, sum(monto + nvl(itbm,0)) as monto");
	sbSql.append(" from tbl_cxp_orden_de_pago_fact where tipo_docto = 'FAC' group by cod_compania, anio, num_orden_pago");
	sbSql.append(") f");
	if (!fg.equalsIgnoreCase("HON")) sbSql.append(", tbl_cxp_orden_de_pago_fact e");
	sbSql.append(", tbl_cxp_orden_de_pago odp");
	sbSql.append(" where a.estado_cheque in ('G','P') and a.cod_compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(sbFilter);
	if (!fg.equalsIgnoreCase("HON")) sbSql.append(" and a.cod_compania_odp = d.cod_compania(+) and a.anio = d.anio(+) and a.num_orden_pago = d.num_orden_pago(+) and a.cod_compania_odp = e.cod_compania(+) and a.anio = e.anio(+) and a.num_orden_pago = e.num_orden_pago(+) and e.tipo_docto(+) = 'FAC'");
	else sbSql.append(" and a.cod_compania_odp = d.cod_compania(+) and a.anio = d.anio(+) and a.num_orden_pago = d.num_orden_pago(+) and odp.generado <> 'H'");
	sbSql.append(" and a.cod_compania_odp = f.cod_compania(+) and a.anio = f.anio(+) and a.num_orden_pago = f.num_orden_pago(+)");
	if (!fg.equalsIgnoreCase("HON")) {
		if (tipo.equalsIgnoreCase("N")) sbSql.append(" and (d.monto != a.monto_girado or nvl(e.numero_factura,'0') in ('0','00'))");
		else sbSql.append(" and (d.monto = a.monto_girado and e.numero_factura not in ('0','00'))");
	} else {
		if (tipo.equalsIgnoreCase("N")) sbSql.append(" and (d.monto != a.monto_girado or nvl(d.num_fact,'0') in ('0','00'))");
		else sbSql.append(" and (d.monto = a.monto_girado and d.num_fact not in ('0','00'))");
	}
	sbSql.append(" and odp.cod_tipo_orden_pago");
	if (!fg.equalsIgnoreCase("HON")) sbSql.append(" in ( select column_value  from table( select split((select get_sec_comp_param(a.cod_compania,'CXP_TIPO_ORD_PAGO') from dual),',') from dual  )) ");
	else sbSql.append(" in (1,3)");
	sbSql.append(" and a.cod_compania_odp = odp.cod_compania and a.anio = odp.anio and a.num_orden_pago = odp.num_orden_pago order by f_emision desc");

	if (request.getParameter("cod_banco") != null) {
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql+")");
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
document.title = 'Pagos Otros - '+document.title;
function facturas(anio, num_orden_pago,tipoBenef,idBeneficiario,cod_tipo_orden){abrir_ventana('../cxp/ingreso_facturas.jsp?fp=orden_pago&fg=pago_sin_fact&num_orden_pago='+num_orden_pago+'&anio='+anio+'&tipoBenef='+tipoBenef+'&idBeneficiario='+idBeneficiario+'&cod_tipo_orden='+cod_tipo_orden+'&generadoPor=<%=fg%>');}
function ver(anio, num_orden_pago,tipoBenef,idBeneficiario,cod_tipo_orden){abrir_ventana('../cxp/ingreso_facturas.jsp?fp=orden_pago&num_orden_pago='+num_orden_pago+'&anio='+anio+'&mode=view&tipoBenef='+tipoBenef+'&idBeneficiario='+idBeneficiario+'&cod_tipo_orden='+cod_tipo_orden+'&generadoPor=<%=fg%>');}
function selCuentaBancaria(i){var cod_banco = eval('document.search01.cod_banco'+i).value;if(cod_banco=='') alert('Seleccione Banco!');else abrir_ventana1('../common/search_cuenta_bancaria.jsp?fp=cheque&cod_banco='+cod_banco+'&index='+i);}
function  printList(toXcel){
	if(!toXcel) abrir_ventana('../cxp/print_list_orden_pago_sin_factura.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>&tipo=<%=tipo%>&fg=<%=fg%>');
	else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=cxp/rpt_list_orden_pago_sin_factura.rptdesign&appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>&tipo=<%=tipo%>&fg=<%=fg%>&pCtrlHeader=true');
}
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}

function correccion(anio, num_orden_pago,tipoBenef,idBeneficiario,cod_tipo_orden){abrir_ventana('../cxp/reg_ingreso_facturas.jsp?fp=orden_pago&num_orden_pago='+num_orden_pago+'&anio='+anio+'&tipoBenef='+tipoBenef+'&idBeneficiario='+idBeneficiario+'&cod_tipo_orden='+cod_tipo_orden+'&generadoPor=<%=fg%>');}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CUENTAS POR PAGAR - CHEQUES"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
		<tr>
				<td align="right">
					<!--<authtype type='3'><a href="javascript:add()" class="Link00">[ Registro Nuevo ]</a></authtype>-->
				</td>
		</tr>
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="0">
					<%
						fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
						<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fg",fg)%>
					<tr class="TextFilter">
					<td>
								<cellbytelabel>Banco</cellbytelabel>
								<%=fb.select(ConMgr.getConnection(),"select cod_banco, cod_banco||' - '||nombre from tbl_con_banco z where exists (select null from tbl_con_cuenta_bancaria where compania = "+session.getAttribute("_companyId")+" and compania = z.compania and cod_banco = z.cod_banco) order by nombre","cod_banco",cod_banco,false,false,0, "text10", "", "", "", "T")%>
								<cellbytelabel>Cta</cellbytelabel>.
								<%=fb.textBox("cuenta_banco",cuenta_banco,false,false,true,10,"text10",null,"")%>
								<%=fb.textBox("nombre_cuenta",nombre_cuenta,false,false,true,25,"text10",null,"")%>
								<%=fb.button("buscarCuenta","...",false, false,"text10","","onClick=\"javascript:selCuentaBancaria('')\"")%>
				<cellbytelabel>Tipo Orden</cellbytelabel>:
							<%=fb.select(ConMgr.getConnection(),"select cod_tipo_orden_pago, descripcion from tbl_cxp_tipo_orden_pago where cod_tipo_orden_pago in "+((fg.equalsIgnoreCase("HON"))?"(1,3)":"( select column_value  from table( select split((select get_sec_comp_param("+session.getAttribute("_companyId")+",'CXP_TIPO_ORD_PAGO') from dual),',') from dual  ))")+" order by cod_tipo_orden_pago","tipoOrden",tipoOrden,false,false,0, "text10", "", "", "", "S")%>
				<%if(fg.trim().equals("HON")){%>
				Pagos A
				<%=fb.select("pagosA","E=Empresa,M=Medico",pagosA, false, false,0,"text10",null,"","","T")%><%}%>
						</td>
						</tr>
					<tr class="TextFilter">
					<td>
					<cellbytelabel>Beneficiario</cellbytelabel>
					<%=fb.textBox("beneficiario",beneficiario,false,false,false,20,"text10",null,"")%>
								<cellbytelabel>No. Cheque</cellbytelabel>
								<%=fb.textBox("num_cheque",num_cheque,false,false,false,20,"text10",null,"")%>
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="2"/>
								<jsp:param name="clearOption" value="true"/>
								<jsp:param name="nameOfTBox1" value="fecha_desde"/>
								<jsp:param name="valueOfTBox1" value="<%=fecha_desde%>"/>
								<jsp:param name="nameOfTBox2" value="fecha_hasta"/>
								<jsp:param name="valueOfTBox2" value="<%=fecha_hasta%>"/>
							</jsp:include>
							<cellbytelabel>Tipo</cellbytelabel>
							<%=fb.select("tipo","F=Facturas Aplicadas, N=Facturas no Aplicadas",tipo,false,false,0,"Text10",null,"")%>
							<br>
							<cellbytelabel>Orden Pago</cellbytelabel>
								<%=fb.textBox("odp",odp,false,false,false,20,"text10",null,"")%>
								<cellbytelabel>Num. Factura</cellbytelabel>
								<%=fb.textBox("factura",factura,false,false,false,20,"text10",null,"")%>
						<%=fb.submit("go","Ir")%>
						</td>
						</tr>
						<%=fb.formEnd()%>
			</table>
		</td>
	</tr>
		<tr>
				<td align="right">
					<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a> | <a href="javascript:printList(1)" class="Link00">[ <cellbytelabel>Imprimir Lista (Excel)</cellbytelabel> ]</a></authtype>
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
				<%=fb.hidden("cod_banco",cod_banco)%>
				<%=fb.hidden("cuenta_banco",cuenta_banco)%>
				<%=fb.hidden("nombre_cuenta",nombre_cuenta)%>
				<%=fb.hidden("num_cheque",num_cheque)%>
				<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("odp",odp)%>
				<%=fb.hidden("factura",factura)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("pagosA",pagosA)%>
				<%=fb.hidden("tipoOrden",tipoOrden)%>
				<%=fb.hidden("beneficiario",beneficiario)%>
				<%=fb.hidden("fecha_desde",fecha_desde)%>
				<%=fb.hidden("fecha_hasta",fecha_hasta)%>
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
					<%=fb.hidden("cod_banco",cod_banco)%>
					<%=fb.hidden("cuenta_banco",cuenta_banco)%>
					<%=fb.hidden("nombre_cuenta",nombre_cuenta)%>
					<%=fb.hidden("num_cheque",num_cheque)%>
					<%=fb.hidden("tipo",tipo)%>
					<%=fb.hidden("odp",odp)%>
					<%=fb.hidden("factura",factura)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("pagosA",pagosA)%>
					<%=fb.hidden("tipoOrden",tipoOrden)%>
					<%=fb.hidden("beneficiario",beneficiario)%>
					<%=fb.hidden("fecha_desde",fecha_desde)%>
					<%=fb.hidden("fecha_hasta",fecha_hasta)%>
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

<%fb = new FormBean("result",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("index","")%>
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td width="12%" align="center" colspan="2"><cellbytelabel>Banco</cellbytelabel></td>
					<td width="24%" align="center" colspan="2"><cellbytelabel>Cuenta Bancaria</cellbytelabel></td>
					<td width="18%"><cellbytelabel>Beneficiario</cellbytelabel></td>
					<td width="6%" align="center"><cellbytelabel>Orden Pago</cellbytelabel></td>
					<td width="8%" align="center"><cellbytelabel>Monto</cellbytelabel></td>
					<td width="8%" align="center"><cellbytelabel>Num. Cheque</cellbytelabel></td>
					<td width="6%" align="center"><cellbytelabel>Fecha Emisi&oacute;n</cellbytelabel></td>
					<td width="6%" align="center"><cellbytelabel>Monto Facturas</cellbytelabel></td>
					<td width="6%">&nbsp;</td>
					<td width="6%">&nbsp;</td>
				</tr>
				<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="right"><%=cdo.getColValue("cod_banco")%></td>
					<td><%=cdo.getColValue("nombre_banco")%></td>
					<td><%=cdo.getColValue("cuenta_banco")%></td>
					<td><%=cdo.getColValue("nombre_cuenta")%></td>
					<td><%=cdo.getColValue("beneficiario")%></td>
					<td><%=cdo.getColValue("num_orden_pago")%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_girado"))%>&nbsp;</td>
					<td align="center"><%=cdo.getColValue("num_cheque")%></td>
					<td align="center"><%=cdo.getColValue("f_emision")%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_facturas"))%></td>
					<td align="center">
					<authtype type='50'>
					<%if(cdo.getColValue("tipo").equals("V")){%>
					<a href="javascript:ver('<%=cdo.getColValue("anio")%>','<%=cdo.getColValue("num_orden_pago")%>','<%=cdo.getColValue("tipoBenef")%>', '<%=cdo.getColValue("num_id_beneficiario")%>','<%=cdo.getColValue("cod_tipo_orden_pago")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Ver</cellbytelabel></a>
					<%} else if(cdo.getColValue("tipo").equals("F")||(fg.trim().equals("HON")&&cdo.getColValue("tipo").equals("N"))){%>
					<a href="javascript:facturas('<%=cdo.getColValue("anio")%>', '<%=cdo.getColValue("num_orden_pago")%>','<%=cdo.getColValue("tipoBenef")%>', '<%=cdo.getColValue("num_id_beneficiario")%>','<%=cdo.getColValue("cod_tipo_orden_pago")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Facturas</cellbytelabel></a>

					<%}%>
					</authtype>

					</td>
					<td align="center">
					<%if(cdo.getColValue("tipo").equals("V")){%>
					<authtype type='52'><a href="javascript:facturas('<%=cdo.getColValue("anio")%>', '<%=cdo.getColValue("num_orden_pago")%>','<%=cdo.getColValue("tipoBenef")%>', '<%=cdo.getColValue("num_id_beneficiario")%>','<%=cdo.getColValue("cod_tipo_orden_pago")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>CORR.</cellbytelabel></a></authtype><%}%>
					</td>
				</tr>
				<%
				}
				%>
			</table>
	<%=fb.formEnd()%>
</div>
</div>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

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
				<%=fb.hidden("num_cheque",num_cheque)%>
				<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("odp",odp)%>
				<%=fb.hidden("factura",factura)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("pagosA",pagosA)%>
				<%=fb.hidden("tipoOrden",tipoOrden)%>
				<%=fb.hidden("beneficiario",beneficiario)%>
				<%=fb.hidden("fecha_desde",fecha_desde)%>
				<%=fb.hidden("fecha_hasta",fecha_hasta)%>
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
					<%=fb.hidden("cod_banco",cod_banco)%>
					<%=fb.hidden("cuenta_banco",cuenta_banco)%>
					<%=fb.hidden("nombre_cuenta",nombre_cuenta)%>
					<%=fb.hidden("num_cheque",num_cheque)%>
					<%=fb.hidden("tipo",tipo)%>
					<%=fb.hidden("odp",odp)%>
					<%=fb.hidden("factura",factura)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("pagosA",pagosA)%>
					<%=fb.hidden("tipoOrden",tipoOrden)%>
					<%=fb.hidden("beneficiario",beneficiario)%>
					<%=fb.hidden("fecha_desde",fecha_desde)%>
					<%=fb.hidden("fecha_hasta",fecha_hasta)%>
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