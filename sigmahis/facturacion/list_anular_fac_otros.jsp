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
String sql = "";
String appendFilter = "";
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");


if(request.getMethod().equalsIgnoreCase("GET"))
{
int recsPerPage=100;
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

	String codigo="",cliente="", fechaFact="";
	if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
	{
		appendFilter += " and upper(f.codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
		codigo = request.getParameter("codigo");
	}
	if (request.getParameter("fechaFact") != null && !request.getParameter("fechaFact").trim().equals(""))
	{
		appendFilter += " and to_char(f.fecha,'dd/mm/yyyy') = '"+request.getParameter("fechaFact")+"'";
		fechaFact = request.getParameter("fechaFact");
	}
	if (request.getParameter("cliente") != null && !request.getParameter("cliente").trim().equals(""))
	{
		 appendFilter += " and upper(b.cliente) like '%"+request.getParameter("cliente").toUpperCase()+"%'";
		 cliente = request.getParameter("cliente");
	}

if(!appendFilter.trim().equals(""))
{
	sql="select  f.codigo,f.compania,nvl(x.pagos,0) pagos, b.tipo_cliente, b.cliente, b.codigo cargos_otros, b.anio anio_otros, to_char(f.fecha,'dd/mm/yyyy') fecha, to_char(f.monto_total,'999,990.00') montoTotal,   nvl((select nvl(w.codigo_dgi,'PENDIENTE') from tbl_fac_dgi_documents w where w.compania=f.compania and w.codigo=f.codigo and w.tipo_docto='FACO'),'') dgi_factura, (select count(*) from tbl_fac_notas_otros nc where nc.compania=f.compania and nc.numero_factura=f.codigo) nCred,   /*(select count(*) pendiente from  tbl_fac_factura a, tbl_fac_cargo_cliente fc where (fc.tipo_cliente  = b.tipo_cliente and fc.cliente = b.cliente and a.compania = f.compania and a.facturar_a = 'O' and fc.num_factura = a.codigo and fc.compania = a.compania and a.facturar_a <> 'A' and a.estatus not in ('C','A') and a.codigo <> f.codigo and fc.num_factura not in  (select a.fac_codigo from tbl_cja_detalle_pago a, tbl_cja_transaccion_pago c where a.compania = f.compania and c.tipo_cliente = 'O' and c.codigo = a.codigo_transaccion and c.anio = a.tran_anio and fc.num_factura = a.fac_codigo and c.rec_status <> 'I') ))*/ 0 pendiente from   tbl_fac_factura f,(select count(*) pagos ,a.fac_codigo, a.compania from  tbl_cja_detalle_pago a, tbl_cja_transaccion_pago b where b.codigo = a.codigo_transaccion and   b.anio   = a.tran_anio and   b.compania = a.compania and b.rec_status <> 'I' group by a.fac_codigo, a.compania) x, tbl_fac_cargo_cliente b where  f.facturar_a = 'O' /*and (f.cliente_alq = 'N' or f.cliente_alq is null)**23-11-2011 EN COMENTARIO PARA ANULAR FACT. INCORRECTA***/ and f.codigo = x.fac_codigo(+) and f.compania = x.compania(+) and b.num_factura  = f.codigo and b.compania =f.compania and f.estatus <> 'A' "+appendFilter+" and b.tipo_transaccion='C'  and f.compania = "+(String) session.getAttribute("_companyId")+" order by f.fecha";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
}
if (searchDisp!=null) searchDisp=searchDisp;
	else searchDisp = "Listado";

	if (searchVal != null && !searchVal.equals("")) searchValDisp=searchVal;
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
document.title = 'Facturas - '+document.title;

function anular(k)
{

var pagos = eval('document.form0.pagos'+k).value ;
var pendiente = 0;//eval('document.form0.pendiente'+k).value ;
var fac_remplazo = eval('document.form0.fac_remplazo'+k).value ;
var compania = eval('document.form0.compania'+k).value ;
var factura = eval('document.form0.codigo'+k).value ;
var fecha = '<%=fecha%>';
var factura = eval('document.form0.codigo'+k).value ;
var tipo_cliente = eval('document.form0.tipo_cliente'+k).value ;
var cliente = eval('document.form0.cliente'+k).value ;

pendiente = getDBData('<%=request.getContextPath()%>','count(*) pendiente','tbl_fac_factura a, tbl_fac_cargo_cliente fc',' (fc.tipo_cliente  = \''+tipo_cliente+'\' and fc.cliente = \''+cliente+'\' and a.compania = '+compania+' and a.facturar_a = \'O\' and fc.num_factura = a.codigo and fc.compania = a.compania and a.facturar_a <> \'A\' and a.estatus not in (\'C\',\'A\') and a.codigo <> \''+factura+'\' and fc.num_factura not in  (select a.fac_codigo from tbl_cja_detalle_pago a, tbl_cja_transaccion_pago c where a.compania = '+compania+' and c.tipo_cliente = \'O\' and c.rec_status <> \'I\' and c.codigo = a.codigo_transaccion and c.anio = a.tran_anio and fc.num_factura = a.fac_codigo) )','');


if(parseInt(pagos)>0 && pendiente =="0")
{
	alert('La Factura a anular tiene pago(s) registrado(s), Y el cliente NO tiene OTRAS Facturas pendientes de pago ESTA FACTURA QUEDARA CON EL PAGO APLICADO..');
}
else if(parseInt(pagos)>0 && parseInt(pendiente)>0 && fac_remplazo =="")
{
	alert('La Factura a anular tiene pago(s) registrado(s). Seleccione Numero de Factura que tomarà el pago,en el campo factura Reemplazo');
}
else
{
	if(confirm('Está seguro de Anular factura de OTROS CLIENTES?'))
	{
		if(executeDB('<%=request.getContextPath()%>','call sp_fac_anular_fact_otros('+compania+',\''+factura+'\',\''+fac_remplazo+'\',to_date(\''+fecha+'\',\'dd/mm/yyyy\'),\'<%=(String) session.getAttribute("_userName") %>\')',''))
		{
			alert('Factura anulada satisfactoriamente...');
			window.location.reload(true);
		}
		else alert('La Factura no se ha Podido Anular');
	}
}

}
function buscaF(k){
var compania = eval('document.form0.compania'+k).value ;
var cliente = eval('document.form0.cliente'+k).value ;
var tipo_cliente = eval('document.form0.tipo_cliente'+k).value ;
var pagos = eval('document.form0.pagos'+k).value ;
var factura = eval('document.form0.codigo'+k).value ;

var pendiente = 0;//eval('document.form0.pendiente'+k).value ;

pendiente = getDBData('<%=request.getContextPath()%>','count(*) pendiente','tbl_fac_factura a, tbl_fac_cargo_cliente fc',' (fc.tipo_cliente  = \''+tipo_cliente+'\' and fc.cliente = \''+cliente+'\' and a.compania = '+compania+' and a.facturar_a = \'O\' and fc.num_factura = a.codigo and fc.compania = a.compania and a.facturar_a <> \'A\' and a.estatus not in (\'C\',\'A\') and a.codigo <> \''+factura+'\' and fc.num_factura not in  (select a.fac_codigo from tbl_cja_detalle_pago a, tbl_cja_transaccion_pago c where a.compania = '+compania+' and c.tipo_cliente = \'O\'  and c.codigo = a.codigo_transaccion and c.anio = a.tran_anio and fc.num_factura = a.fac_codigo and c.rec_status <> \'I\' ) )','');

	// select count(*) pendiente from  tbl_fac_factura a, tbl_fac_cargo_cliente fc where (fc.tipo_cliente  = B.TIPO_CLIENTE and fc.cliente = B.CLIENTE and a.compania = F.COMPANIA and a.facturar_a = 'O' and fc.num_factura = a.codigo and fc.compania = a.compania and a.facturar_a <> 'A' and a.estatus not in ('C','A') and a.codigo <> F.CODIGO and fc.num_factura not in  (select a.fac_codigo from tbl_cja_detalle_pago a, tbl_cja_transaccion_pago c where a.compania = F.COMPANIA and c.tipo_cliente = 'O' and c.codigo = a.codigo_transaccion and c.anio = a.tran_anio and fc.num_factura = a.fac_codigo) )

if(parseInt(pagos)>0)
{
	if(parseInt(pendiente)>0)
	{
		if(confirm('LA FACTURA A ANULAR TIENE PAGO REGISTRADO, Y SE ENCONTRO OTRAS FACTURAS PENDIENTES DE PAGO PUEDE TRANFERIR ESTE PAGO, A UNA DE LAS FACTURAS QUE REEMPLACE A LA QUE ESTA ANULANDO'))
		{
		alert('Seleccione el número de factura que tomarà el pago,en el campo factura Reemplazo ');
		abrir_ventana2('../facturacion/sel_fac_remplazo.jsp?index='+k+'&cliente='+cliente+'&tipo_cliente='+tipo_cliente+'&compania='+compania);
		}
	}else alert('La Factura a anular tiene pago(s) registrado(s), Y el cliente NO tiene OTRAS Facturas pendientes de pago ESTA FACTURA QUEDARA CON EL PAGO APLICADO..');
}
else alert('El Cliente no Tiene Facturas pendientes de pago')
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="FACTURAS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
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
				<td width="25%">&nbsp;No. Factura
							<%=fb.textBox("codigo","",false,false,false,15,null,null,null)%>
				</td>
				<td width="25%">&nbsp;Fecha:
					          <jsp:include page="../common/calendar.jsp" flush="true">
					            <jsp:param name="noOfDateTBox" value="1" />
					            <jsp:param name="nameOfTBox1" value="fechaFact" />
					            <jsp:param name="valueOfTBox1" value="" />
					            <jsp:param name="fieldClass" value="" />
					            <jsp:param name="buttonClass" value="" />
								<jsp:param name="clearOption" value="true" />
					          </jsp:include>
				</td>
				<td width="50%">&nbsp;Cliente
							<%=fb.textBox("cliente","",false,false,false,30,null,null,null)%>
							<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
			</tr>


			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>

</table>
<tr><td colspan="2">&nbsp;</td></tr>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%
fb = new FormBean("topPrevious",request.getContextPath()+request.getServletPath());
%>
					<%=fb.formStart()%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("cliente",""+cliente)%>
					<%=fb.hidden("fechaFact",""+fechaFact)%>

					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>

<%
fb = new FormBean("topNext",request.getContextPath()+request.getServletPath());
%>
					<%=fb.formStart()%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("cliente",""+cliente)%>
					<%=fb.hidden("fechaFact",""+fechaFact)%>
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
<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("index","")%>
<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="dirc">
	<tr class="TextHeader" align="center">
		<td width="10%">&nbsp;No. Factura</td>
		<td width="10%">&nbsp;Fecha</td>
		<td width="30%">&nbsp;Cliente</td>
		<td width="10%">&nbsp;Monto</td>
		<td width="14%">&nbsp;Factura DGI</td>
		<td width="15%">&nbsp;Factura Reemplazo</td>
		<td width="8%" align="right"></td>
		<td width="3%">&nbsp;</td>

	</tr>

	<%
	for (int i=0; i<al.size(); i++)
	{
	 CommonDataObject cdo = (CommonDataObject) al.get(i);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
%>
	<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
	<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
	<%=fb.hidden("cliente"+i,cdo.getColValue("cliente"))%>
	<%=fb.hidden("tipo_cliente"+i,cdo.getColValue("tipo_cliente"))%>
	<%=fb.hidden("pagos"+i,cdo.getColValue("pagos"))%>
	<%=fb.hidden("pendiente"+i,cdo.getColValue("pendiente"))%>

	<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" >
		<td align="center">&nbsp;<%=cdo.getColValue("codigo")%></td>
		<td align="center">&nbsp;<%=cdo.getColValue("fecha")%></td>
		<td>&nbsp;<%=cdo.getColValue("cliente")%></td>
		<td align="right">&nbsp;<%=cdo.getColValue("montoTotal")%></td>
		<td align="center">&nbsp;<%=cdo.getColValue("dgi_factura")%></td>
		<td>&nbsp;
		<%=fb.textBox("fac_remplazo"+i,"",false,false,true,15,"Text10",null,null)%>

		<%=fb.button("buscar","...",false,false,"","","onClick=\"javascript:buscaF("+i+")\"")%> </td>
		<td align="center">&nbsp;<%if (cdo.getColValue("dgi_factura").trim().equals("")||cdo.getColValue("dgi_factura").trim().equals("PENDIENTE")||cdo.getColValue("nCred").trim().equals("0")) {%>
		<a href="javascript:anular(<%=i%>)" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Anular</a><%}%></td>
		<td align="center"></td>
	</tr>
	<%
	}
	%>

</table>
<%=fb.formEnd()%>
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
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("cliente",""+cliente)%>
					<%=fb.hidden("fechaFact",""+fechaFact)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>

					<%//list_hon_liquidables.jsp
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
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("cliente",""+cliente)%>
					<%=fb.hidden("fechaFact",""+fechaFact)%>
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