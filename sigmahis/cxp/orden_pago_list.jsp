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
StringBuffer sql = new StringBuffer();
String appendFilter = "";
String nom_beneficiario = request.getParameter("nom_beneficiario");
String num_orden_pago = request.getParameter("num_orden_pago");
String fecha_desde = request.getParameter("fecha_desde");
String fecha_hasta = request.getParameter("fecha_hasta");
String estado = request.getParameter("estado");
String cod_tipo_orden_pago = request.getParameter("cod_tipo_orden_pago");
String numFactura = request.getParameter("numFactura");
String fg = request.getParameter("fg");

if(nom_beneficiario == null) nom_beneficiario = "";
if(num_orden_pago == null) num_orden_pago = "";
if(fecha_desde == null) fecha_desde = "";
if(fecha_hasta == null) fecha_hasta = "";
if(estado == null) estado = "";
if(cod_tipo_orden_pago == null) cod_tipo_orden_pago = "";
if(numFactura == null) numFactura = "";
if(fg == null) fg = "";
if (fg.trim().equals("PM")) cod_tipo_orden_pago = "4";
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

	if (!nom_beneficiario.equals("")){appendFilter += " and upper(a.nom_beneficiario) like '%"+nom_beneficiario.toUpperCase()+"%'";}
	if (!num_orden_pago.equals("")){appendFilter += " and a.num_orden_pago = "+num_orden_pago;}
    if (!fecha_desde.trim().equals("")){appendFilter += " and trunc(a.fecha_solicitud) >= to_date('"+fecha_desde+"','dd/mm/yyyy')";}
    if (!fecha_hasta.trim().equals("")){appendFilter += " and trunc(a.fecha_solicitud) <= to_date('"+fecha_hasta+"','dd/mm/yyyy')";}
	if (!estado.equals("")){appendFilter += " and a.estado = '"+estado+"'";}
	if (!cod_tipo_orden_pago.equals("")){appendFilter += " and a.cod_tipo_orden_pago = "+cod_tipo_orden_pago;}
	if (fg.trim().equals("HON")) appendFilter += " and a.cod_tipo_orden_pago = 1";
	

  if(request.getParameter("fecha_hasta")!=null){

    if (!numFactura.equals("")){if(!fg.trim().equals("CXPHON")) appendFilter += " and b.num_factura = '"+numFactura+"'";}

   sql.append("select a.cod_compania, a.anio, a.num_orden_pago, to_char(a.fecha_solicitud, 'dd/mm/yyyy') fecha_solicitud, a.estado, decode(a.estado,'P','PENDIENTE','A', 'APROBADO','R','RECHAZADO','N','ANULADO',a.estado) as estado_desc, a.nom_beneficiario, decode(a.cod_medico, null,a.num_id_beneficiario,(select nvl(reg_medico,codigo) from tbl_adm_medico where codigo =a.cod_medico))  as num_id_beneficiario, a.cod_tipo_orden_pago, a.monto, a.tipo_orden from tbl_cxp_orden_de_pago a");
   if(!numFactura.equals("")&&!fg.trim().equals("CXPHON")){sql.append(",tbl_cxp_detalle_orden_pago b ");}

   sql.append(" where a.compania=");
   sql.append(session.getAttribute("_companyId"));
   sql.append(appendFilter);
   if(!numFactura.equals("")&&!fg.trim().equals("CXPHON")){sql.append(" and a.cod_compania =b.cod_compania and a.anio = b.anio and a.num_orden_pago =b.num_orden_pago");}

   if(fg.trim().equals("CXPHON")){sql.append(" and exists ( select 1 from tbl_cxp_orden_de_pago_fact fac where  fac.tipo_docto = 'FAC' and fac.cod_compania =a.cod_compania and fac.anio =a.anio and fac.num_orden_pago =a.num_orden_pago and fac.numero_factura = '");
   sql.append(numFactura);
    sql.append("' )");}

   sql.append(" order by a.fecha_solicitud desc");


  al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql.toString()+")");
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
function add(){abrir_ventana('../cxp/orden_pago.jsp?fg=<%=fg%>');}
function ver(num_orden_pago, anio){abrir_ventana('../cxp/orden_pago.jsp?mode=view&num_orden_pago='+num_orden_pago+'&anio='+anio);}
function printList(){abrir_ventana2('../cxp/print_list_orden_pago.jsp?numFactura=<%=numFactura%>&fg=<%=fg%>&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');}
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
        <td align="right"><%if(!fg.trim().equals("CXPHON")){%><authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel>Registro Nuevo</cellbytelabel> ]</a></authtype><%}%>
	    	</td>
    </tr>
	<tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="1">
			    <tr class="TextFilter">
                    <%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
				    <%=fb.formStart(true)%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("numFactura",numFactura)%>
					<%=fb.hidden("fg",fg)%>

				    <td><cellbytelabel>Nombre Benef.</cellbytelabel>:
								<%=fb.textBox("nom_beneficiario",nom_beneficiario,false,false,false,30,"text10",null,"")%>
                <cellbytelabel>No. Orden Pago</cellbytelabel>
                <%=fb.intBox("num_orden_pago",num_orden_pago,false,false,false,10,"text10",null,"")%>
                <jsp:include page="../common/calendar.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="2"/>
                <jsp:param name="clearOption" value="true"/>
                <jsp:param name="nameOfTBox1" value="fecha_desde"/>
                <jsp:param name="valueOfTBox1" value="<%=fecha_desde%>"/>
                <jsp:param name="nameOfTBox2" value="fecha_hasta"/>
                <jsp:param name="valueOfTBox2" value="<%=fecha_hasta%>"/>
                <jsp:param name="fieldClass" value="text10"/>
                <jsp:param name="buttonClass" value="text10"/>
              </jsp:include>
              <cellbytelabel>Estado</cellbytelabel>:
              <%=fb.select("estado","P=Pendiente,A=Aprobado,N=Anulado",estado, false, false, 0, "text10", "", "", "", "S")%>
              <cellbytelabel>Tipo Orden</cellbytelabel>:
              <%=fb.select(ConMgr.getConnection(),"select cod_tipo_orden_pago, descripcion from tbl_cxp_tipo_orden_pago where cod_tipo_orden_pago in "+((!fg.trim().equals("HON"))?(!fg.trim().equals("PM")?"(1, 2, 3)":"(4)"):"(1)")+"order by cod_tipo_orden_pago","cod_tipo_orden_pago",cod_tipo_orden_pago,false,false,0, "text10", "", "", "", "S")%>
						<%=fb.submit("go","Ir")%>
            </td>
			 <%fb.appendJsValidation("if((document.search01.fecha_desde.value!='' && !isValidateDate(document.search01.fecha_desde.value))||(document.search01.fecha_hasta.value!='' && !isValidateDate(document.search01.fecha_hasta.value))){alert('Formato de fecha inválida!');error++;}");%>
				<%=fb.formEnd(true)%>	   </tr>
			</table>
		</td>
	</tr>
    <tr>
        <td align="right">
		  		<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype>
				</td>
    </tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
				<%=fb.hidden("nom_beneficiario",nom_beneficiario)%>
				<%=fb.hidden("num_orden_pago",num_orden_pago)%>
				<%=fb.hidden("fecha_desde",fecha_desde)%>
				<%=fb.hidden("fecha_hasta",fecha_hasta)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("cod_tipo_orden_pago",cod_tipo_orden_pago)%>
				<%=fb.hidden("numFactura",numFactura)%>
				<%=fb.hidden("fg",fg)%>
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
					<%=fb.hidden("nom_beneficiario",nom_beneficiario)%>
					<%=fb.hidden("num_orden_pago",num_orden_pago)%>
					<%=fb.hidden("fecha_desde",fecha_desde)%>
					<%=fb.hidden("fecha_hasta",fecha_hasta)%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("cod_tipo_orden_pago",cod_tipo_orden_pago)%>
					<%=fb.hidden("numFactura",numFactura)%>
					<%=fb.hidden("fg",fg)%>
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
					<td width="6%" align="center"><cellbytelabel>No. Orden Pago</cellbytelabel></td>
          <td width="6%" align="center"><cellbytelabel>Fecha</cellbytelabel></td>
					<td width="34%"><cellbytelabel>Beneficiario</cellbytelabel></td>
					<td width="8%" align="center"><cellbytelabel>Monto</cellbytelabel></td>
          <td width="8%" align="center"><cellbytelabel>Estado</cellbytelabel></td>
					<td width="8%">&nbsp;</td>
				</tr>
				<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("num_orden_pago")%></td>
					<td><%=cdo.getColValue("fecha_solicitud")%></td>
					<td><%=cdo.getColValue("num_id_beneficiario")%>&nbsp;-&nbsp;<%=cdo.getColValue("nom_beneficiario")%></td>
          <td align="right"><%=cdo.getColValue("monto")%>&nbsp;</td>
          <td><%=cdo.getColValue("estado_desc")%></td>
					<td align="center">
					<authtype type='4'><a href="javascript:ver(<%=cdo.getColValue("num_orden_pago")%>, '<%=cdo.getColValue("anio")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Ver</cellbytelabel></a></authtype>
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
				<%=fb.hidden("nom_beneficiario",nom_beneficiario)%>
				<%=fb.hidden("num_orden_pago",num_orden_pago)%>
				<%=fb.hidden("fecha_desde",fecha_desde)%>
				<%=fb.hidden("fecha_hasta",fecha_hasta)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("cod_tipo_orden_pago",cod_tipo_orden_pago)%>
				<%=fb.hidden("numFactura",numFactura)%>
				<%=fb.hidden("fg",fg)%>
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
					<%=fb.hidden("nom_beneficiario",nom_beneficiario)%>
					<%=fb.hidden("num_orden_pago",num_orden_pago)%>
					<%=fb.hidden("fecha_desde",fecha_desde)%>
					<%=fb.hidden("fecha_hasta",fecha_hasta)%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("cod_tipo_orden_pago",cod_tipo_orden_pago)%>
					<%=fb.hidden("numFactura",numFactura)%>
					<%=fb.hidden("fg",fg)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

</body>
</html>
<%
}
%>