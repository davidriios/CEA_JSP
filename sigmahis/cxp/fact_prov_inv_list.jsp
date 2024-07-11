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
String proveedor = request.getParameter("proveedor");
String numero_documento = request.getParameter("numero_documento");
String fecha_desde = request.getParameter("fecha_desde");
String fecha_hasta = request.getParameter("fecha_hasta");
String estado = request.getParameter("estado");
String cod_tipo_orden_pago = request.getParameter("cod_tipo_orden_pago");
if(proveedor == null) proveedor = "";
if(numero_documento == null) numero_documento = "";
if(fecha_desde == null) fecha_desde = "";
if(fecha_hasta == null) fecha_hasta = "";
if(estado == null) estado = "";
if(cod_tipo_orden_pago == null) cod_tipo_orden_pago = "";

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

	if (!proveedor.equals("")){
    appendFilter += " and upper(b.nombre_proveedor) like '%"+proveedor.toUpperCase()+"%'";
  }

	if (!numero_documento.equals("")){
    appendFilter += " and a.numero_factura = '"+numero_documento+"'";
  }

  if (!fecha_desde.trim().equals("")){
    appendFilter += " and trunc(a.fecha_documento) >= to_date('"+fecha_desde+"','dd/mm/yyyy')";
	}

  if (!fecha_hasta.trim().equals("")){
    appendFilter += " and trunc(a.fecha_documento) <= to_date('"+fecha_hasta+"','dd/mm/yyyy')";
	}

	if (!estado.equals("")){
    appendFilter += " and a.estado = '"+estado+"'";
  }

  sql = "select to_char(a.fecha_sistema, 'dd/mm/yyyy') fecha_sistema, a.numero_documento, a.compania, a.anio_recepcion, to_char(a.fecha_documento, 'dd/mm/yyyy') fecha_documento, a.numero_factura, a.monto_total, a.itbm, a.cod_proveedor, a.cod_concepto, a.explicacion, a.usuario_creacion, a.estado, a.ref_cheque, a.correccion, b.nombre_proveedor, nvl(c.monto, 0) monto_op, nvl(c.monto_pagado, 0) monto_pagado,c.odp , a.anio_recepcion||' - '||a.numero_documento as recep from tbl_inv_recepcion_material a, tbl_com_proveedor b, ( select a.anio||' - '||a.num_orden_pago as odp,a.num_id_beneficiario cod_proveedor, b.numero_factura as num_factura, sum (b.monto+b.itbm) as monto, sum(b.monto+b.itbm) monto_pagado from tbl_cxp_orden_de_pago a, tbl_cxp_orden_de_pago_fact b, tbl_con_cheque c where a.estado = 'A' and a.anio = b.anio and a.num_orden_pago = b.num_orden_pago and a.cod_compania = b.cod_compania and a.cod_tipo_orden_pago = 2 and b.numero_factura is not null and a.anio = c.anio(+) and a.num_orden_pago = c.num_orden_pago(+) and a.cod_compania = c.cod_compania_odp(+) and b.tipo_docto = 'FAC' and c.estado_cheque <> 'A' group by a.num_id_beneficiario, b.numero_factura, a.anio||' - '||a.num_orden_pago ) c where a.estado = 'R' and a.tipo_factura = 'I' and a.fre_documento not in ('NE') and a.cod_proveedor = b.cod_provedor and a.cod_proveedor = c.cod_proveedor(+) and a.numero_factura = c.num_factura(+) and a.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" order by a.fecha_documento desc";
 if(request.getParameter("proveedor")!=null){
  al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  
  rowCount = CmnMgr.getCount("SELECT count(*) from ("+sql+")");
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
document.title = 'Pagos Otros - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CUENTAS POR PAGAR - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="1">
			    <tr class="TextFilter">		
                    <%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
				    <%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				    <td><cellbytelabel>Nombre Proveedor</cellbytelabel>:
								<%=fb.textBox("proveedor",proveedor,false,false,false,30,"text10",null,"")%> 
                <cellbytelabel>No. Factura</cellbytelabel>:
                <%=fb.textBox("numero_documento",numero_documento,false,false,false,10,"text10",null,"")%> 
                <jsp:include page="../common/calendar.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="2" />
                <jsp:param name="clearOption" value="true" />
                <jsp:param name="nameOfTBox1" value="fecha_desde" />
                <jsp:param name="valueOfTBox1" value="<%=fecha_desde%>" />
                <jsp:param name="nameOfTBox2" value="fecha_hasta" />
                <jsp:param name="valueOfTBox2" value="<%=fecha_hasta%>" />
                <jsp:param name="fieldClass" value="text10" />
                <jsp:param name="buttonClass" value="text10" />
              </jsp:include>
              <cellbytelabel>Estado</cellbytelabel>:
              <%=fb.select("estado","R=Recibido,A=Anulado",estado, false, false, 0, "text10", "", "", "", "S")%>
						<%=fb.submit("go","Ir")%>		  
            </td>
				    <%=fb.formEnd()%>	   </tr>
			</table>
		</td>
	</tr>
    <tr>
        <td align="right">
		  		<authtype type='0'><!--<a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a>--></authtype>
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
        <%=fb.hidden("proveedor",proveedor)%>
        <%=fb.hidden("numero_documento",numero_documento)%>
        <%=fb.hidden("fecha_desde",fecha_desde)%>
        <%=fb.hidden("fecha_hasta",fecha_hasta)%>
        <%=fb.hidden("estado",estado)%>
        <%=fb.hidden("cod_tipo_orden_pago",cod_tipo_orden_pago)%>
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
        <%=fb.hidden("proveedor",proveedor)%>
        <%=fb.hidden("numero_documento",numero_documento)%>
        <%=fb.hidden("fecha_desde",fecha_desde)%>
        <%=fb.hidden("fecha_hasta",fecha_hasta)%>
        <%=fb.hidden("estado",estado)%>
        <%=fb.hidden("cod_tipo_orden_pago",cod_tipo_orden_pago)%>
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
	
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td width="6%" align="center"><cellbytelabel>No. Recepcion</cellbytelabel></td>
         			<td width="6%" align="center"><cellbytelabel>Fecha</cellbytelabel></td>
					<td width="28%"><cellbytelabel>Proveedor</cellbytelabel></td>
          			<td width="8%" align="center"><cellbytelabel>N&uacute;mero Factura</cellbytelabel></td>
					<td width="8%" align="center"><cellbytelabel>Monto</cellbytelabel></td>
					<td width="6%" align="center"><cellbytelabel>No. Orden</cellbytelabel></td>
					<td width="4%"><cellbytelabel>Monto Orden P</cellbytelabel>.</td>
					<td width="4%"><cellbytelabel>Monto Pagado</cellbytelabel></td>
				</tr>				
				<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("recep")%></td>
					<td><%=cdo.getColValue("fecha_documento")%></td>
					<td><%=cdo.getColValue("cod_proveedor")%>&nbsp;-&nbsp;<%=cdo.getColValue("nombre_proveedor")%></td>
          			<td align="center"><%=cdo.getColValue("numero_factura")%></td>
         			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_total"))%>&nbsp;</td>
		  			<td><%=cdo.getColValue("odp")%></td>
					<td align="center"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_op"))%>&nbsp;
					</td>
					<td align="center"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_pagado"))%>&nbsp;
					</td>
				</tr>
				<%
				}
				%>							
			</table>
	
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
        <%=fb.hidden("proveedor",proveedor)%>
        <%=fb.hidden("numero_documento",numero_documento)%>
        <%=fb.hidden("fecha_desde",fecha_desde)%>
        <%=fb.hidden("fecha_hasta",fecha_hasta)%>
        <%=fb.hidden("estado",estado)%>
        <%=fb.hidden("cod_tipo_orden_pago",cod_tipo_orden_pago)%>
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
        <%=fb.hidden("proveedor",proveedor)%>
        <%=fb.hidden("numero_documento",numero_documento)%>
        <%=fb.hidden("fecha_desde",fecha_desde)%>
        <%=fb.hidden("fecha_hasta",fecha_hasta)%>
        <%=fb.hidden("estado",estado)%>
        <%=fb.hidden("cod_tipo_orden_pago",cod_tipo_orden_pago)%>
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