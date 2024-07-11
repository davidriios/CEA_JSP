<%//@ page errorPage="../error.jsp"%>
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
String descuento = request.getParameter("descuento");
String turno = request.getParameter("turno");
String cajero = request.getParameter("cajero");

if(fg == null) fg = "";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	CommonDataObject cdoF = SQLMgr.getData("select '01/'||to_char(sysdate, 'mm/yyyy') fecha_desde, to_char(sysdate, 'dd/mm/yyyy') fecha_hasta from dual");
	if(fecha_desde==null || fecha_desde.equals("")) fecha_desde = cdoF.getColValue("fecha_desde");
	if(fecha_hasta==null || fecha_hasta.equals("")) fecha_hasta = cdoF.getColValue("fecha_hasta");
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
	if(descuento==null) descuento = "";
	if(cajero==null) cajero = "";
	if(turno==null) turno = "";
	
  sbSql.append("select a.doc_id, a.other3 cod_factura, a.doc_date fecha, to_char(a.doc_date, 'dd/mm/yyyy') doc_date, a.client_id, a.client_name, b.codigo, b.cantidad, abs(b.precio) precio, (b.cantidad * abs(b.precio)) monto_descuento, replace(b.descripcion, 'DESC. ', '') articulo, b.valor_descuento, b.id_descuento, c.codigo desc_codigo, c.descripcion descuento_desc, c.valor desc_valor from tbl_fac_trx a, tbl_fac_trxitems b, tbl_par_descuento c where a.doc_id = b.doc_id and a.company_id = b.compania and b.id_descuento = c.id and a.company_id = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	if(!client_name.equals("")){
		sbSql.append(" and a.client_name like '%");
		sbSql.append(client_name);
		sbSql.append("%'");
	}
	if(!fecha_desde.equals("")){
		sbSql.append(" and trunc(a.doc_date) >= to_date('");
		sbSql.append(fecha_desde);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!fecha_hasta.equals("")){
		sbSql.append(" and trunc(a.doc_date) <= to_date('");
		sbSql.append(fecha_hasta);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!no_factura.equals("")){
		sbSql.append(" and a.other3 = '");
		sbSql.append(no_factura);
		sbSql.append("'");
	}	
	if(!descuento.equals("")){
		sbSql.append(" and b.id_descuento = ");
		sbSql.append(descuento);
	}
	if(!cajero.equals("")){
		sbSql.append(" and a.cod_cajero = '");
		sbSql.append(cajero);
		sbSql.append("'");
	}
	if(!turno.equals("")){
		sbSql.append(" and a.turno = ");
		sbSql.append(turno);
	}

  sbSql.append("order by c.descripcion, a.client_name, b.descripcion");

  sbSqlAll.append("select * from (select rownum as rn, a.* from (");
	sbSqlAll.append(sbSql.toString());
	sbSqlAll.append(") a) where rn between ");
	sbSqlAll.append(previousVal);
	sbSqlAll.append(" and ");
	sbSqlAll.append(nextVal);
  al = SQLMgr.getDataList(sbSqlAll.toString());
  rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql.toString()+") z");
	sbSqlAll = new StringBuffer();
	sbSqlAll.append("select id_descuento, descuento_desc, sum(cantidad) cantidad, sum(precio) precio, sum(cantidad*precio) monto_descuento from (");
	sbSqlAll.append(sbSql.toString());
	sbSqlAll.append(") group by id_descuento, descuento_desc");
	alT = SQLMgr.getDataList(sbSqlAll.toString());
	for(int i = 0; i<alT.size();i++){
		CommonDataObject ct = (CommonDataObject) alT.get(i);
		htT.put(ct.getColValue("id_descuento")+"_"+ct.getColValue("descuento_desc"), ct);
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
	var descuento 			= document.search01.descuento.value;
	var cajero 			= document.search01.cajero.value;
	var turno 			= document.search01.turno.value;
	abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=pos/ventas_descuento.rptdesign&cltNameParam='+client_name+'&noFacturaParam='+no_factura+'&fechaDesdeParam='+fDate+'&fechaHastaParam='+tDate+'&cajeroParam='+cajero+'&turnoParam='+turno+'&descParam='+descuento);
}

function showTurno()
{
var cajero = document.search01.cajero.value ;
if(cajero=='') alert('Seleccione Cajero!');
else abrir_ventana2('../caja/turnos_list.jsp?fp=ventas_descuento&cod_cajera='+cajero);
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
					Descuento:
					<%=fb.select(ConMgr.getConnection(),"select id, id||'-'||descripcion from tbl_par_descuento where compania = "+(String) session.getAttribute("_companyId")+" order by descripcion","descuento",descuento,false,false,0,"text10",null,"", "", "S")%>
					Cajero:
					<%=fb.select(ConMgr.getConnection(),"select cod_cajera, lpad(cod_cajera, 3, '0') ||' - ' || nombre descripcion from tbl_cja_cajera where compania = "+(String) session.getAttribute("_companyId")+" order by nombre asc","cajero",cajero,false,false,0,"text10",null,"", "", "S")%>
  				Turno:
					<%=fb.textBox("turno",turno,false,false,false,5)%>
					<%=fb.button("addTurno","...",true,false,null,null,"onClick=\"javascript:showTurno()\"","Seleccionar Turno")%>
          <%=fb.submit("go","Ir")%> 
					<!--Esconder Header-->
					<%//=fb.checkbox("pCtrlHeader","")%>
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
					<%=fb.hidden("descuento",descuento)%>
					<%=fb.hidden("turno",turno)%>
					<%=fb.hidden("cajero",cajero)%>
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
					<%=fb.hidden("descuento",descuento)%>
					<%=fb.hidden("turno",turno)%>
					<%=fb.hidden("cajero",cajero)%>
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
					<td width="10%">No. Factura</td>
					<td width="10%">Fecha</td>
					<td width="25%">Nombre de Cliente</td>
					<td width="25%">Art&iacute;culo</td>
					<td width="10%">Cantidad</td>
					<td width="10%">Monto Descuento</td>
					<td width="10%">Total Descuento</td>
				</tr>
				<%
				String descuento_desc = "";
				String id_descuento = "", key = "";
				double desc = 0.00, precio = 0.00;
				int cantidad = 0;
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
       <%
					if(i!=0 && !key.equals(cdo.getColValue("id_descuento")+"_"+cdo.getColValue("descuento_desc"))){
						if(htT.containsKey(key)){
						CommonDataObject ct = (CommonDataObject) htT.get(key);
				%>
				<tr class="Text10Bold">
          <td colspan="4" align="right">Total <%=descuento_desc%>:</td>
          <td align="right"><%=ct.getColValue("cantidad")%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(ct.getColValue("precio"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(ct.getColValue("monto_descuento"))%></td>
        </tr>
				<%
					}
				}
				%>
				<%
				if(!descuento_desc.equals(cdo.getColValue("descuento_desc"))){%>
        <tr class="Text10Bold">
          <td colspan="11"><%=cdo.getColValue("descuento_desc")%></td>
				</tr>
				<%}
				
				%>
        <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
          <td align="center"><%=cdo.getColValue("cod_factura")%></td>
          <td align="center"><%=cdo.getColValue("doc_date")%></td>
          <td><%=cdo.getColValue("client_name")%></td>
          <td><%=cdo.getColValue("articulo")%></td>
          <td align="right"><%=cdo.getColValue("cantidad")%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("precio"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_descuento"))%></td>
        </tr>
        <%
					key = cdo.getColValue("id_descuento")+"_"+cdo.getColValue("descuento_desc");
					descuento_desc = cdo.getColValue("descuento_desc");
					id_descuento = cdo.getColValue("id_descuento");
					cantidad += Integer.parseInt(cdo.getColValue("cantidad"));
					desc += Double.parseDouble(cdo.getColValue("monto_descuento"));
					precio += Double.parseDouble(cdo.getColValue("precio"));
				}
				%>
        <%
					if(htT.containsKey(key)){
						CommonDataObject ct = (CommonDataObject) htT.get(key);
				%>
				<tr class="Text10Bold">
          <td colspan="4" align="right">Total <%=descuento_desc%>:</td>
          <td align="right"><%=ct.getColValue("cantidad")%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(ct.getColValue("precio"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(ct.getColValue("monto_descuento"))%></td>
        </tr>
				<%}%>
				<tr class="Text10Bold">
          <td colspan="4" align="right">TOTAL DE DESCUENTO:</td>
          <td align="right"><%=cantidad%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(precio)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(desc)%></td>
        </tr>
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
					<%=fb.hidden("descuento",descuento)%>
					<%=fb.hidden("turno",turno)%>
					<%=fb.hidden("cajero",cajero)%>
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
					<%=fb.hidden("descuento",descuento)%>
					<%=fb.hidden("turno",turno)%>
					<%=fb.hidden("cajero",cajero)%>
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
