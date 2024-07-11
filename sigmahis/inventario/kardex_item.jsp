<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.compras.OrdenCompra"%>
<%@ page import="issi.compras.OrdenCompraDetail"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==========================================================================================
==========================================================================================
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

int saldo = 0;
String mode = request.getParameter("mode");
String id = request.getParameter("id");
int anio = 2010;//Integer.parseInt(request.getParameter("anio"));
int prevAnio = anio -1;
String fp = request.getParameter("fp");
String filterProveedor = request.getParameter("filterProveedor");
String tipo_mov = "";
String art_clase = "";
String cod_articulo = "";
String descripcion = "";
String almacen = "";
String fDate = "";
String tDate = "";
String agrupado = "";
String flia_kardex = "";

int totSaldo;
if(request.getParameter("tipo_mov")!=null) tipo_mov = request.getParameter("tipo_mov");
if(request.getParameter("art_clase")!=null) art_clase = request.getParameter("art_clase");
if(request.getParameter("cod_articulo")!=null) cod_articulo = request.getParameter("cod_articulo");
if(request.getParameter("descripcion")!=null) descripcion = request.getParameter("descripcion");
if(request.getParameter("almacen")!=null) almacen = request.getParameter("almacen");
if(request.getParameter("fDate")!=null) fDate = request.getParameter("fDate");
if(request.getParameter("tDate")!=null) tDate = request.getParameter("tDate");
if(request.getParameter("agrupado")!=null) agrupado = request.getParameter("agrupado");
if(request.getParameter("flia_kardex")!=null) flia_kardex = request.getParameter("flia_kardex");

if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 500;
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

	CommonDataObject cdSI = new CommonDataObject();
	sbSql.append("select sum(cantidad) saldo_inicial from (select nvl(cantidad,0) cantidad from tbl_inv_qty_inicial where compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and almacen = ");
	sbSql.append(almacen);
	sbSql.append(" and cod_articulo = ");
	sbSql.append(cod_articulo);
	sbSql.append(" union all select sum(qty_in-qty_out+qty_aju) from vw_inv_mov_item where compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and codigo_almacen = ");
	sbSql.append(almacen);
	sbSql.append(" and cod_articulo = ");
	sbSql.append(cod_articulo);
	sbSql.append(" and trunc(fecha_docto) < to_date('");
	sbSql.append(fDate);
	sbSql.append("', 'dd/mm/yyyy'))");
	cdSI = SQLMgr.getData(sbSql.toString());

	sbSql = new StringBuffer();

	sbSql.append("select a.tipo, a.tipo_desc, a.tipo_docto,");
	if(agrupado.trim().equals("S"))sbSql.append(" '' as anio_docto, '' as no_docto, '' as fecha_docto, '' pac_id, '' admision, '' cod_extra ");
	else sbSql.append(" a.anio_trx as anio_docto, a.no_docto, to_char(a.fecha_sistema, 'dd/mm/yyyy hh12:mi am') fecha_docto, a.pac_id, a.admision, a.cod_extra");

	sbSql.append(" , a.compania, a.codigo_almacen,");
		
	if(flia_kardex.equalsIgnoreCase("TRX"))sbSql.append(" a.cod_familia, a.cod_clase,");
	else sbSql.append(" a.flia_art as cod_familia, a.clase_art as cod_clase,");
	
	sbSql.append("   a.cod_articulo, a.descripcion, ");
	if(agrupado.trim().equals("S"))sbSql.append("  sum(a.qty_in) as qty_in, sum(a.qty_out) as qty_out , sum(a.qty_aju) as qty_aju, sum((a.qty_in - a.qty_out + a.qty_aju)) as ");
	else sbSql.append("  a.qty_in, a.qty_out, a.qty_aju, (a.qty_in - a.qty_out + a.qty_aju)");

	sbSql.append(" saldo, (select descripcion from tbl_inv_almacen ia where ia.compania = a.compania and ia.codigo_almacen = a.codigo_almacen) almacen_desc from vw_inv_mov_item a where compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	if (!fDate.equals("")){
		sbSql.append(" and trunc(a.fecha_docto) >= to_date('");
		sbSql.append(fDate);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if (!tDate.equals("")){
		sbSql.append(" and trunc(a.fecha_docto) <= to_date('");
		sbSql.append(tDate);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if (!cod_articulo.equals("")){
		sbSql.append(" and a.cod_articulo = ");
		sbSql.append(cod_articulo);
	}
	if (!almacen.equals("")){
		sbSql.append(" and a.codigo_almacen = ");
		sbSql.append(almacen);
	}
	if (!tipo_mov.equals("")){
		sbSql.append(" and a.tipo_mov = '");
		sbSql.append(tipo_mov.toUpperCase());
		sbSql.append("'");
	}

	if(agrupado.trim().equals("S")){ sbSql.append(" group by a.tipo,a.tipo_desc, a.tipo_docto, '', '', '', a.compania, a.codigo_almacen, ");
	
	if(flia_kardex.equalsIgnoreCase("TRX"))sbSql.append(" a.cod_familia, a.cod_clase,");
	else sbSql.append(" a.flia_art, a.clase_art,");
	
	 sbSql.append("  a.cod_articulo, a.descripcion ");}

	if(!agrupado.trim().equals("S"))sbSql.append(" order by a.fecha_sistema asc, a.codigo_almacen, a.descripcion");

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);

	rowCount = CmnMgr.getCount("select count(*) count FROM ("+sbSql.toString()+")");

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
document.title = 'Inventario - '+document.title;
</script>
<script language="javascript">

function showDocto(i){
	var anio = eval('document.articles.anio_docto'+i).value;
	var no = eval('document.articles.no_docto'+i).value;
	var tipo = eval('document.articles.tipo'+i).value;
	var tipo_docto = eval('document.articles.tipo_docto'+i).value;
	var url='', fg='';
	if(tipo=='REC' || tipo=='AREC'){
		if(tipo_docto=='OC') fg='COC';
		else if(tipo_docto=='FC' || tipo_docto=='FR') fg='SOC';
		else if(tipo_docto=='NE') fg='CNE';
		else if(tipo_docto=='FG') fg='CFP';
		url = '../inventario/reg_recepcion_con_oc.jsp?fg='+fg+'&mode=view&id='+no+'&anio='+anio;
		if(fg=='SOC') url = '../inventario/reg_recepcion_sin_oc.jsp?fg='+fg+'&mode=view&id='+no+'&anio='+anio;
		if(tipo_docto=='NE') url = '../inventario/reg_recepcion_nentrega.jsp?fg='+fg+'&mode=view&id='+no+'&anio='+anio;
		if(tipo_docto=='FG') url = '../inventario/reg_recepcion_fact_prov.jsp?fg='+fg+'&mode=view&id='+no+'&anio='+anio;
	} else if(tipo=='ENT'){
		if(tipo_docto=='U') fg='UA';
		else if(tipo_docto=='A') fg='EA';
		else fg='MP';
		url = '../inventario/vw_delivery.jsp?fg='+fg+'&mode=view&no='+no+'&anio='+anio;
	} else if(tipo=='AJU'){
		var cod_ajuste = eval('document.articles.cod_extra'+i).value;
		url = '../inventario/reg_ajuste.jsp?fg='+tipo_docto+'&mode=view&numero='+no+'&codigo='+cod_ajuste+'&anio='+anio;
	} else if(tipo=='DEV'){
		if(tipo_docto=='UA') fg='UA';
		else if(tipo_docto=='EA') fg='EA';
		if(tipo_docto=='UA' || tipo_docto=='EA') url = '../inventario/reg_devolucion.jsp?fg='+tipo_docto+'&mode=view&id='+no+'&anio='+anio;
	}	else if(tipo_docto=='DEVPA'){
			var pac_id = eval('document.articles.pac_id'+i).value;
			var admision = eval('document.articles.admision'+i).value;
			url = '../inventario/dev_mat_pacientes.jsp?fg=DM&fp=PAC_O&mode=view&id='+no+'&anio='+anio+'&pacId='+pac_id+'&noAdmision='+admision;
	} else if(tipo_docto=='DEVPR'){
		url = '../inventario/reg_dev_proveedor.jsp?fg=DP&mode=view&id='+no+'&anio='+anio;
	} else if(tipo_docto=='NCP' || tipo_docto=='FACP'){
		var docId = eval('document.articles.cod_extra'+i).value;
		url = '../facturacion/ver_impresion_dgi.jsp?fg=kardex&docId='+docId+'&tipoDocto='+tipo_docto;
	}	else if(tipo_docto=='CARGO'){
			var pac_id = eval('document.articles.pac_id'+i).value;
			var admision = eval('document.articles.admision'+i).value;
			var tipo_tran = eval('document.articles.cod_extra'+i).value;
			url = '../facturacion/print_cargo_dev.jsp?pacId='+pac_id+'&noSecuencia='+admision+'&printOF=S&codigo='+no+'&tipoTransaccion='+tipo_tran;
	} else if(tipo=='REQA'){
		url = '../inventario/reg_req_unid_adm.jsp?mode=view&id='+no+'&anio='+anio+'&tipoSolicitud='+tipo_docto+'&tr=EA';
	}
	if(url!='')abrir_ventana(url);
}
function showReport(){
	var fDate 			= document.search01.fDate.value;
	var tDate 			= document.search01.tDate.value;
	var almacen 		= document.search01.almacen.value;
	var cod_articulo 			= document.search01.cod_articulo.value;
	var tipo_mov 			= document.search01.tipo_mov.value;
	abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=inventario/kardex_det.rptdesign&almacenParam='+almacen+'&articuloParam='+cod_articulo+'&fechaDesdeParam='+fDate+'&fechaHastaParam='+tDate+'&tipoMovParam='+tipo_mov+'&pFlia_kardex=<%=flia_kardex%>&pCtrlHeader=false');
}
</script>

</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="COMPRAS - SELECCION DE ARTICULOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">&nbsp;<!--<a href="javascript:print()">[ Imprimir ]</a>--></td>
  </tr>
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="0" cellspacing="0">
				<% fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp"); %>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("anio",""+anio)%>
				<%=fb.hidden("fp",""+fp)%>
				<%=fb.hidden("almacen",""+almacen)%>
				<%=fb.hidden("cod_articulo",""+cod_articulo)%>
				<%=fb.hidden("tipo_mov",""+tipo_mov)%>
			<tr class="TextFilter">
				<td>
					Fecha:
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="2" />
					<jsp:param name="clearOption" value="true" />
					<jsp:param name="nameOfTBox1" value="fDate" />
					<jsp:param name="valueOfTBox1" value="<%=fDate%>" />
					<jsp:param name="nameOfTBox2" value="tDate" />
					<jsp:param name="valueOfTBox2" value="<%=tDate%>" />
					</jsp:include> &nbsp;&nbsp;AGRUPAR POR TIPO<%=fb.checkbox("agrupado","S",agrupado.equals("S"),false)%>
					<%=fb.submit("go","Ir")%>
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
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("anio",""+anio)%>
				<%=fb.hidden("fp",""+fp)%>
				<%=fb.hidden("cod_articulo",cod_articulo)%>
				<%=fb.hidden("almacen",almacen)%>
				<%=fb.hidden("fDate",fDate)%>
				<%=fb.hidden("tDate",tDate)%>
				<%=fb.hidden("tipo_mov",""+tipo_mov)%>
				<%=fb.hidden("agrupado",""+agrupado)%>
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
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("anio",""+anio)%>
				<%=fb.hidden("fp",""+fp)%>
				<%=fb.hidden("cod_articulo",cod_articulo)%>
				<%=fb.hidden("almacen",almacen)%>
				<%=fb.hidden("fDate",fDate)%>
				<%=fb.hidden("tDate",tDate)%>
				<%=fb.hidden("tipo_mov",""+tipo_mov)%>
				<%=fb.hidden("agrupado",""+agrupado)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
<tr>
	<td align="right"><authtype type='0'><a href="javascript:showReport()" class="Link00">[ Reporte ]</a></authtype></td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%
fb = new FormBean("articles","","post","");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("anio",""+anio)%>
				<%=fb.hidden("fp",""+fp)%>
				<%=fb.hidden("agrupado",""+agrupado)%>
<tr>
	<td class="TableLeftBorder TableRightBorder" colspan="2">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="0" cellspacing="1">
			<tr class="TextHeader">
				<td width="26%" align="center" colspan="3">Documento</td>
				<td width="18%" align="center" colspan="3">C&oacute;digo</td>
				<td width="26%" align="center" rowspan="2">Descripci&oacute;n</td>
				<td width="21%" align="center" colspan="3">Cantidad</td>
				<td width="9%" align="center" rowspan="2">Saldo</td>
			</tr>
			<tr class="TextHeader">
				<td width="13%" align="center">Tipo</td>
				<td width="6%" align="center">N&uacute;mero</td>
				<td width="10%" align="center">Fecha</td>
				<td width="5%" align="center">Familia</td>
				<td width="5%" align="center">Clase</td>
				<td width="5%" align="center">Art&iacute;culo</td>
				<td width="7%" align="center">Entrada</td>
				<td width="7%" align="center">Salida</td>
				<td width="7%" align="center">Ajuste</td>
			</tr>
			<tr class="Text10Bold"><td colspan="10" align="right">Saldo Inicial</td><td align="center"><%=cdSI.getColValue("saldo_inicial")%></td></tr>
<%
String flg = "S";

if(cdSI!=null && !cdSI.getColValue("saldo_inicial").equals("") && flg.equals("S"))
{
saldo = Integer.parseInt(cdSI.getColValue("saldo_inicial"));
flg = "N";
}
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	if(!cdo.getColValue("qty_in").equals("")) saldo += Integer.parseInt(cdo.getColValue("qty_in"));
	if(!cdo.getColValue("qty_out").equals("")) saldo -= Integer.parseInt(cdo.getColValue("qty_out"));
	if(!cdo.getColValue("qty_aju").equals("")) saldo += Integer.parseInt(cdo.getColValue("qty_aju"));

%>
		<%=fb.hidden("no_docto"+i,cdo.getColValue("no_docto"))%>
		<%=fb.hidden("anio_docto"+i,cdo.getColValue("anio_docto"))%>
		<%=fb.hidden("tipo"+i,cdo.getColValue("tipo"))%>
		<%=fb.hidden("tipo_docto"+i,cdo.getColValue("tipo_docto"))%>
		<%=fb.hidden("pac_id"+i,cdo.getColValue("pac_id"))%>
		<%=fb.hidden("admision"+i,cdo.getColValue("admision"))%>
		<%=fb.hidden("cod_extra"+i,cdo.getColValue("cod_extra"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
      <td align="left">&nbsp;
	  <%if(!agrupado.trim().equals("S")){%><label  class="<%=color%>" style="cursor:pointer"><label class="RedTextBold">&nbsp;&nbsp;<a href="javascript:showDocto(<%=i%>);" class="RedTextBold"><%=cdo.getColValue("tipo_desc")%></a>&nbsp;&nbsp;</label></label>&nbsp;<%}else{%>
	  <%=cdo.getColValue("tipo_desc")%>
	  <%}%>

	  </td>
      <td align="center"><%=cdo.getColValue("no_docto")%></td>
      <td align="left"><%=cdo.getColValue("fecha_docto")%></td>
			<td align="center"><%=cdo.getColValue("cod_familia")%></td>
			<td align="center"><%=cdo.getColValue("cod_clase")%></td>
			<td align="center"><%=cdo.getColValue("cod_articulo")%></td>
			<td align="left"><%=cdo.getColValue("descripcion")%></td>
			<td align="center"><%=cdo.getColValue("qty_in")%></td>
			<td align="center"><%=cdo.getColValue("qty_out")%></td>
			<td align="center"><%=cdo.getColValue("qty_aju")%></td>
			<td align="center"><%=saldo%></td>
		</tr>
	<%
}
if(al.size()==0){
%>
		<tr><td align="center" colspan="11">No registros encontrados.</td></tr>
<%}%>
		</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.formEnd()%>
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
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("anio",""+anio)%>
				<%=fb.hidden("fp",""+fp)%>
				<%=fb.hidden("tipo_mov",tipo_mov)%>
				<%=fb.hidden("art_clase",art_clase)%>
				<%=fb.hidden("cod_articulo",cod_articulo)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<%=fb.hidden("almacen",almacen)%>
				<%=fb.hidden("fDate",fDate)%>
				<%=fb.hidden("tDate",tDate)%>
				<%=fb.hidden("tipo_mov",""+tipo_mov)%>
				<%=fb.hidden("agrupado",""+agrupado)%>
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
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("anio",""+anio)%>
				<%=fb.hidden("fp",""+fp)%>
				<%=fb.hidden("tipo_mov",tipo_mov)%>
				<%=fb.hidden("art_clase",art_clase)%>
				<%=fb.hidden("cod_articulo",cod_articulo)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<%=fb.hidden("almacen",almacen)%>
				<%=fb.hidden("fDate",fDate)%>
				<%=fb.hidden("tDate",tDate)%>
				<%=fb.hidden("tipo_mov",""+tipo_mov)%>
				<%=fb.hidden("agrupado",""+agrupado)%>
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
