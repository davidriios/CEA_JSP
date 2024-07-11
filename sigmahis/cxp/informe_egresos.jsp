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
<jsp:useBean id="_companyId" scope="session" class="java.lang.String" />
<jsp:useBean id="htT" scope="page" class="java.util.Hashtable" />
<%
/*
==========================================================================================
==========================================================================================
*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alT = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbSqlAll = new StringBuffer();
String appendFilter = "";
String compId = _companyId;
String fg = request.getParameter("fg");
String fecha_desde = request.getParameter("fecha_desde");
String fecha_hasta = request.getParameter("fecha_hasta");
String filtrado_por = request.getParameter("filtrado_por");
String client_name = request.getParameter("client_name");
String no_factura = request.getParameter("no_factura");
String cajero = request.getParameter("cajero");
String turno = request.getParameter("turno");
if(fecha_desde==null) fecha_desde="";
if(fecha_hasta==null) fecha_hasta="";
if(fg == null) fg = "";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	/*
	CommonDataObject cdoF = SQLMgr.getData("select '01/'||to_char(sysdate, 'mm/yyyy') fecha_desde, to_char(sysdate, 'dd/mm/yyyy') fecha_hasta from dual");
	if(fecha_desde==null || fecha_desde.equals("")) fecha_desde = cdoF.getColValue("fecha_desde");
	if(fecha_hasta==null || fecha_hasta.equals("")) fecha_hasta = cdoF.getColValue("fecha_hasta");
  */
	int recsPerPage = 1000;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  if (request.getParameter("searchQuery") != null){
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }
	
	if(request.getParameter("client_name")==null) client_name = "";
	if(request.getParameter("no_factura")==null) no_factura = "";
	if(cajero==null) cajero = "";
	if(turno==null) turno = "";
	
  sbSql.append("select d.*, to_char(d.fecha_documento, 'dd/mm/yyyy') fecha, nvl((select sum(monto) from tbl_cxp_orden_de_pago_fact where tipo_docto = 'FAC' and cod_compania = d.compania and numero_factura = d.numero_factura), 0) pagos, (select nombre_proveedor from tbl_com_proveedor where compania = d.compania and cod_provedor = d.cod_proveedor) client_name from (select e.compania, e.anio_recepcion, e.numero_documento, (case when e.fre_documento = 'FR' or (e.fre_documento = 'FC' and e.anio_recepcion is null) then 'SOC' when e.fre_documento = 'OC' or (e.fre_documento = 'FC' and e.anio_recepcion is not null) then 'COC' else e.fre_documento end) tipo_docto, e.numero_factura, e.fecha_documento, e.cod_proveedor, nvl(e.descuento, 0) descuento, e.subtotal total_venta, sum(decode(e.fre_documento, 'FR', decode(nvl(d.art_itbm, 0), 0, d.cantidad * (d.precio-nvl(d.art_itbm, 0)), 0), 0)) cr_monto_no_gravable, sum(decode(e.fre_documento, 'FR', decode(nvl(d.art_itbm, 0), 0, 0, d.cantidad * (d.precio-nvl(d.art_itbm, 0))), 0)) cr_monto_gravable, sum(decode(e.fre_documento, 'FR', 0, decode(nvl(d.art_itbm, 0), 0, d.cantidad * (d.precio-nvl(d.art_itbm, 0)), 0))) co_monto_no_gravable, sum(decode(e.fre_documento, 'FR', 0, decode(nvl(d.art_itbm, 0), 0, 0, decode(e.fre_documento, 'FG', d.cantidad * d.precio, d.cantidad * (d.precio-nvl(d.art_itbm, 0)))))) co_monto_gravable, sum(nvl(decode(e.fre_documento, 'FR', decode(nvl(d.art_itbm, 0), 0, 0, d.cantidad * d.art_itbm), 0), 0)) cr_itbm, sum(nvl(decode(e.fre_documento, 'FR', 0, decode(nvl(d.art_itbm, 0), 0, 0, decode(e.fre_documento, 'FG', 1, d.cantidad) * d.art_itbm)), 0)) co_itbm, e.monto_total net_amount from tbl_inv_recepcion_material e, tbl_inv_detalle_recepcion d where e.anio_recepcion = d.anio_recepcion and e.numero_documento = d.numero_documento and e.compania = d.compania and e.estado='R' ");
	if(!fecha_desde.equals("")){
		sbSql.append(" and trunc(fecha_documento) >= to_date('");
		sbSql.append(fecha_desde);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!fecha_hasta.equals("")){
		sbSql.append(" and trunc(e.fecha_documento) <= to_date('");
		sbSql.append(fecha_hasta);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!no_factura.equals("")){
		sbSql.append(" and e.numero_factura = '");
		sbSql.append(no_factura);
		sbSql.append("'");
	}	
	sbSql.append(" and e.compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" group by e.compania, e.anio_recepcion, e.numero_documento, (case when e.fre_documento = 'FR' or (e.fre_documento = 'FC' and e.anio_recepcion is null) then 'SOC' when e.fre_documento = 'OC' or (e.fre_documento = 'FC' and e.anio_recepcion is not null) then 'COC' else e.fre_documento end), e.numero_factura, e.fecha_documento, e.cod_proveedor, e.subtotal, nvl(e.descuento, 0), e.monto_total) d");
	if(!client_name.equals("")){
		sbSql.append(" where exists (select null  from tbl_com_proveedor where compania = d.compania and cod_provedor = d.cod_proveedor and nombre_proveedor like '%");
		sbSql.append(IBIZEscapeChars.forSingleQuots(client_name));
		sbSql.append("%')"); 
	}	
	sbSql.append(" order by d.fecha_documento desc");

  sbSqlAll.append("select * from (select rownum as rn, a.* from (");
	sbSqlAll.append(sbSql.toString());
	sbSqlAll.append(") a) where rn between ");
	sbSqlAll.append(previousVal);
	sbSqlAll.append(" and ");
	sbSqlAll.append(nextVal);
	if(!fecha_desde.equals("") && !fecha_hasta.equals("")){
  al = SQLMgr.getDataList(sbSqlAll.toString());
  rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql.toString()+") z");
	sbSqlAll = new StringBuffer();
	sbSqlAll.append("select sum(0) total_venta, sum(co_monto_no_gravable) co_monto_no_gravable, sum(co_monto_gravable) co_monto_gravable, sum(co_itbm) co_itbm, sum(cr_monto_no_gravable) cr_monto_no_gravable, sum(cr_monto_gravable) cr_monto_gravable,  sum(cr_itbm) cr_itbm, sum(0) net_amount, sum(pagos) pagos, sum(descuento) descuento from (");
	sbSqlAll.append(sbSql.toString());
	sbSqlAll.append(")");
	/*alT = SQLMgr.getDataList(sbSqlAll.toString());
	for(int i = 0; i<alT.size();i++){
		CommonDataObject ct = (CommonDataObject) alT.get(i);
		htT.put(ct.getColValue("tipo_doc"), ct);
	}*/
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
document.title = 'Informe de ingresos - '+document.title;

function printList()
{	
	abrir_ventana('');
}

function showReport(){
	var fDate 			= document.search01.fecha_desde.value;
	var tDate 			= document.search01.fecha_hasta.value;
	var client_name 		= document.search01.client_name.value;
	var no_factura 			= document.search01.no_factura.value;
	var pCtrlHeader = document.search01.pCtrlHeader.checked;
	abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=cxp/informe_de_egresos.rptdesign&cltNameParam='+client_name.replace("'", "''")+'&noFacturaParam='+no_factura+'&fechaDesdeParam='+fDate+'&fechaHastaParam='+tDate+'&pCtrlHeader='+pCtrlHeader);
}

function showDoc(fg,anio, id){
	if (fg=='COC'){abrir_ventana('../inventario/reg_recepcion_con_oc.jsp?fg='+fg+'&mode=view&id='+id+'&anio='+anio);
	} else if (fg=='SOC'){abrir_ventana('../inventario/reg_recepcion_sin_oc.jsp?fg='+fg+'&mode=view&id='+id+'&anio='+anio);
	} else if (fg=='NE'){abrir_ventana('../inventario/reg_recepcion_nentrega.jsp?fg='+fg+'&mode=view&id='+id+'&anio='+anio);
	} else if (fg=='FG'){abrir_ventana('../inventario/reg_recepcion_fact_prov.jsp?fg='+fg+'&mode=view&id='+id+'&anio='+anio);
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value=""></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td><!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
      <table width="100%" cellpadding="0" cellspacing="0">
        <tr class="TextFilter">
          <%
					  fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
          <%=fb.formStart()%> 
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> 
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%> 
					<%=fb.hidden("fg",fg)%>
          <td>Fecha: 
          <jsp:include page="../common/calendar.jsp" flush="true">
          <jsp:param name="noOfDateTBox" value="2" />
          <jsp:param name="clearOption" value="true" />
          <jsp:param name="nameOfTBox1" value="fecha_desde" />
          <jsp:param name="valueOfTBox1" value="<%=fecha_desde%>" />
          <jsp:param name="nameOfTBox2" value="fecha_hasta" />
          <jsp:param name="valueOfTBox2" value="<%=fecha_hasta%>" />
          </jsp:include>
					&nbsp;&nbsp;
					Cliente:
					<%=fb.textBox("client_name",client_name,false,false,false,40,"Text10",null,"")%> 
          &nbsp;&nbsp;
					No. Factura:
					<%=fb.textBox("no_factura",no_factura,false,false,false,12,"Text10",null,"")%> 
          <%=fb.submit("go","Ir")%> 
					Esconder Header
					<%=fb.checkbox("pCtrlHeader","")%>
          </td>
          <%=fb.formEnd()%> </tr>
      </table>
      <!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
    </td>
  </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableLeftBorder TableTopBorder TableRightBorder"><table align="center" width="100%" cellpadding="1" cellspacing="0">
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
					<%=fb.hidden("no_factura",no_factura)%> 
					<%=fb.hidden("client_name",client_name)%> 
					<%=fb.hidden("fecha_desde",fecha_desde)%> 
					<%=fb.hidden("fecha_hasta",fecha_hasta)%> 
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("cajero",cajero)%>
					<%=fb.hidden("turno",turno)%>
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
					<%=fb.hidden("no_factura",no_factura)%> 
					<%=fb.hidden("client_name",client_name)%> 
					<%=fb.hidden("fecha_desde",fecha_desde)%> 
					<%=fb.hidden("fecha_hasta",fecha_hasta)%> 
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("cajero",cajero)%>
					<%=fb.hidden("turno",turno)%>
          <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
          <%=fb.formEnd()%> </tr>
      </table></td>
  </tr>
	<tr>
		<td align="right"><authtype type='0'><a href="javascript:showReport()" class="Link00">[ Reporte ]</a></authtype></td>
	</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableLeftBorder TableRightBorder"><!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
      <table align="center" width="100%" cellpadding="0" cellspacing="1">
        <tr class="TextHeader" align="center">
					<td rowspan="2" width="7%">No. Factura</td>
					<td rowspan="2" width="7%">Fecha</td>
					<td rowspan="2" width="18%">Nombre de Cliente</td>
					<td rowspan="2" width="8%">Subtotal</td>
					<td colspan="2" width="17%">Compra Contado</td>
					<td rowspan="2" width="4%">ITBM</td>
					<td colspan="2" width="17%">Compra Credito</td>
					<td rowspan="2" width="4%">ITBM</td>
					<td rowspan="2" width="4%">Desc.</td>
					<td rowspan="2" width="10%">Ctas x Pagar</td>
					<td rowspan="2" width="5%">Pagos</td>
				</tr>
        <tr class="TextHeader" align="center">
					<td >No Gravable</td>
					<td >Gravable</td>
					<td >No Gravable</td>
					<td >Gravable</td>
				</tr>
				<%
				String tipo_doc = "";
				double total_venta = 0.00, co_no_gravable = 0.00, co_gravable = 0.00, co_tax_amount = 0.00, cr_no_gravable = 0.00, cr_gravable = 0.00, cr_tax_amount = 0.00, descuento = 0.00, net_amount = 0.00, pago = 0.00; 
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<!--
				<tr class="Text10Bold">
          <td colspan="3" align="right">Total:</td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(total_venta)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(co_no_gravable)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(co_gravable)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(co_tax_amount)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cr_no_gravable)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cr_gravable)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cr_tax_amount)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(descuento)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(net_amount)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(pago)%></td>
        </tr>
				-->
				<%
				total_venta = 0.00; co_no_gravable = 0.00; co_gravable = 0.00; co_tax_amount = 0.00; cr_no_gravable = 0.00; cr_gravable = 0.00; cr_tax_amount = 0.00; descuento = 0.00; net_amount = 0.00; pago = 0.00;
				%>
        <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
          <td align="center"><a href="javascript:showDoc('<%=cdo.getColValue("tipo_docto")%>',<%=cdo.getColValue("anio_recepcion")%>,<%=cdo.getColValue("numero_documento")%>)" class="Link00 Text10"><%=cdo.getColValue("numero_factura")%></a></td>
          <td><%=cdo.getColValue("fecha")%></td>
          <td><%=cdo.getColValue("client_name")%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("total_venta"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("co_monto_no_gravable"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("co_monto_gravable"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("co_itbm"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("cr_monto_no_gravable"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("cr_monto_gravable"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("cr_itbm"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("descuento"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("net_amount"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("pagos"))%></td>
        </tr>
        <%
					total_venta += Double.parseDouble(cdo.getColValue("total_venta")); 
					co_no_gravable += Double.parseDouble(cdo.getColValue("co_monto_no_gravable"));
					co_gravable += Double.parseDouble(cdo.getColValue("co_monto_gravable"));
					co_tax_amount += Double.parseDouble(cdo.getColValue("co_itbm"));
					cr_no_gravable += Double.parseDouble(cdo.getColValue("cr_monto_no_gravable"));
					cr_gravable += Double.parseDouble(cdo.getColValue("cr_monto_gravable"));
					cr_tax_amount += Double.parseDouble(cdo.getColValue("cr_itbm"));
					descuento += Double.parseDouble(cdo.getColValue("descuento"));
					net_amount += Double.parseDouble(cdo.getColValue("net_amount"));
					pago += Double.parseDouble(cdo.getColValue("pagos"));
				}
				%>
        <%
					if(al.size()!=0){
				%>
				<tr class="Text10Bold">
          <td colspan="3" align="right">Total:</td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(total_venta)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(co_no_gravable)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(co_gravable)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(co_tax_amount)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cr_no_gravable)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cr_gravable)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cr_tax_amount)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(descuento)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(net_amount)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(pago)%></td>
        </tr>
				<%}%>
     </table>
      <!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
    </td>
  </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableLeftBorder TableBottomBorder TableRightBorder"><table align="center" width="100%" cellpadding="1" cellspacing="0">
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
					<%=fb.hidden("no_factura",no_factura)%> 
					<%=fb.hidden("client_name",client_name)%> 
					<%=fb.hidden("fecha_desde",fecha_desde)%> 
					<%=fb.hidden("fecha_hasta",fecha_hasta)%> 
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("cajero",cajero)%>
					<%=fb.hidden("turno",turno)%>
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
					<%=fb.hidden("no_factura",no_factura)%> 
					<%=fb.hidden("client_name",client_name)%> 
					<%=fb.hidden("fecha_desde",fecha_desde)%> 
					<%=fb.hidden("fecha_hasta",fecha_hasta)%> 
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("cajero",cajero)%>
					<%=fb.hidden("turno",turno)%>
          <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
          <%=fb.formEnd()%> </tr>
      </table></td>
  </tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
