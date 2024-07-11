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
String factura = request.getParameter("factura");

if(proveedor == null) proveedor = "";
if(numero_documento == null) numero_documento = "";
if(fecha_desde == null) fecha_desde = "";
if(fecha_hasta == null) fecha_hasta = "";
if(estado == null) estado = "";
if(cod_tipo_orden_pago == null) cod_tipo_orden_pago = "";
if(factura == null) factura = "";

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
    appendFilter += " and trim(upper(b.nombre_proveedor)) like '%"+proveedor.toUpperCase().trim()+"%'";
  }
	if (!numero_documento.equals("")){
    appendFilter += " and a.numero_documento = "+numero_documento;
  }
  if (!factura.equals("")){
    appendFilter += " and  upper(a.numero_factura) like '%"+factura.toUpperCase()+"%'";
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
 if(request.getParameter("factura") != null){
  sql = "select to_char(a.fecha_sistema, 'dd/mm/yyyy') fecha_sistema, a.numero_documento, a.compania, a.anio_recepcion, to_char(a.fecha_documento, 'dd/mm/yyyy') fecha_documento, a.numero_factura, a.monto_total, a.itbm, a.cod_proveedor, a.cod_concepto, a.explicacion, a.usuario_creacion, decode(a.estado,'R','RECIBIDO','A','ANULADO',a.estado) estado, a.ref_cheque, a.correccion, b.nombre_proveedor,a.estado status from tbl_inv_recepcion_material a, tbl_com_proveedor b where a.estado in ('A','R') and a.tipo_factura = 'S' and a.cod_proveedor = b.cod_provedor and a.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" order by a.fecha_documento desc";
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
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Pagos Otros - '+document.title;

function add()
{
	abrir_ventana('../cxp/fact_prov.jsp');
}

function ver(numero_documento, anio)
{
	abrir_ventana('../cxp/fact_prov.jsp?mode=view&numero_documento='+numero_documento+'&anio='+anio);
}

function editar(numero_documento, anio)
{
	abrir_ventana('../cxp/fact_prov.jsp?mode=edit&numero_documento='+numero_documento+'&anio='+anio);
}

function printList(){
 //abrir_ventana2('../cxp/print_list_orden_pago.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
 var proveedor = $("#proveedor").val().toUpperCase().trim() || 'ALL';
 var numDoc = $("#numero_documento").val() || 'ALL';
 var factura = $("#factura").val() || 'ALL';
 var fd = $("#fecha_desde").toRptFormat() || '1900-01-01';
 var fh = $("#fecha_hasta").toRptFormat() || '1900-01-01';
 var status = $("#estado").val() || 'ALL';
 var pCtrlHeader = $("#show_hide_hdr").prop("checked") || false;
 abrir_ventana2("../cellbyteWV/report_container.jsp?reportName=cxp/rpt_fact_prov_list.rptdesign&pProveedor="+proveedor+"&pNumDoc="+numDoc+"&pFactura="+factura+"&fDesde="+fd+"&fHasta="+fh+"&pStatus="+status+"&pCtrlHeader="+pCtrlHeader);
}


jQuery(document).ready(function(){
  $("#test").click(function(e){
	 var fd = $("#fecha_desde").toRptFormat();
	 debug(fd);
    // e.preventDefault();
  });
});
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
        <td align="right">
	    		<authtype type='3'><a href="javascript:add()" class="Link00">[ Registro Nuevo ]</a></authtype>
	    	</td>
    </tr>
	<tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="1">
			    <tr class="TextFilter">		
                    <%
					  fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
				    <%=fb.formStart(true)%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				    <td>Beneficiario:
								<%=fb.textBox("proveedor",proveedor,false,false,false,30,"text10",null,"")%> 
                <cellbytelabel>No. Documento</cellbytelabel>
                <%=fb.intBox("numero_documento",numero_documento,false,false,false,10,"text10",null,"")%> 
				 <cellbytelabel>No. Factura</cellbytelabel>
                <%=fb.textBox("factura",factura,false,false,false,10,"text10",null,"")%> 
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
				    <%=fb.formEnd(true)%>	   </tr>
			</table>
		</td>
	</tr>
    <tr>
        <td align="right">
		  <authtype type='0'>
			<a href="javascript:printList()" class="Link00" id="test">[ Imprimir Lista ]</a>
		  </authtype>
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
		<%=fb.hidden("factura",factura)%>
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
		<%=fb.hidden("factura",factura)%>
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
					<td width="6%" align="center"><cellbytelabel>No. Doc.</cellbytelabel></td>
          <td width="6%" align="center"><cellbytelabel>Fecha</cellbytelabel></td>
					<td width="30%"><cellbytelabel>Proveedor</cellbytelabel></td>
					<td width="4%"><cellbytelabel>Estado</cellbytelabel></td>

          <td width="8%" align="center"><cellbytelabel>N&uacute;mero Factura</cellbytelabel></td>
					<td width="8%" align="center"><cellbytelabel>Monto</cellbytelabel></td>
					<td width="4%">&nbsp;</td>
					<td width="4%">&nbsp;</td>
				</tr>				
				<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("numero_documento")%></td>
					<td><%=cdo.getColValue("fecha_documento")%></td>
					<td><%=cdo.getColValue("cod_proveedor")%>&nbsp;-&nbsp;<%=cdo.getColValue("nombre_proveedor")%></td>
					<td><%=cdo.getColValue("estado")%></td>
          <td align="center"><%=cdo.getColValue("numero_factura")%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_total"))%>&nbsp;</td>
					<td align="center">
					<authtype type='1'><a href="javascript:ver(<%=cdo.getColValue("numero_documento")%>, '<%=cdo.getColValue("anio_recepcion")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Ver</cellbytelabel></a></authtype>
					</td>
					<td align="center">
<%					
if(cdo.getColValue("status").trim().equals("R"))
{
%>
					<authtype type='4'><a href="javascript:editar(<%=cdo.getColValue("numero_documento")%>, '<%=cdo.getColValue("anio_recepcion")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Editar</cellbytelabel></a></authtype>
					
					<%
					}
					%>
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
		<%=fb.hidden("factura",factura)%>
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
		<%=fb.hidden("factura",factura)%>
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