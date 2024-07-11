<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.facturacion.Factura"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="FactMgr" scope="page" class="issi.facturacion.FacturaMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==========================================================================================
==========================================================================================
**/
SecMgr.setConnection(ConMgr);

if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
/*
*/
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
FactMgr.setConnection(ConMgr);

/*
*/

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fgFilter = "";
String fg = request.getParameter("fg");
if(fg==null) fg = "xxx";
if(fg.equals("xxx")){
	fgFilter = "";
} else if(fg.equals("yyy")){
	fgFilter = "";
}
if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
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

	String secuencia    = "";  // variable para mantener el valor de los campos filtrados en la consulta
	String codPaciente  = "";
	String nombre       = "";

	if (request.getParameter("codigo") != null && !request.getParameter("codigo").equals("")){
		appendFilter += " and upper(a.codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    searchOn = "a.codigo";
    searchVal = request.getParameter("codigo");
    searchType = "1";
    searchDisp = "No. Documento";
	}
	if (request.getParameter("cliente") != null && !request.getParameter("cliente").equals("")){
		appendFilter += " and upper(a.cliente) like '%"+request.getParameter("cliente").toUpperCase()+"%'";
    searchOn = "a.cliente";
    searchVal = request.getParameter("cliente");
    searchType = "2";
    searchDisp = "Cliente";
	}
	if (request.getParameter("anio") != null && !request.getParameter("anio").equals("")){
		appendFilter += " and a.anio = "+request.getParameter("anio");
    searchOn = "a.anio";
    searchVal = request.getParameter("anio");
    searchType = "1";
    searchDisp = "Año";
	}
	if (request.getParameter("num_factura") != null && !request.getParameter("num_factura").equals("")){
		appendFilter += " and upper(a.num_factura) like '%"+request.getParameter("num_factura").toUpperCase()+"%'";
    searchOn = "a.num_factura";
    searchVal = request.getParameter("num_factura");
    searchType = "1";
    searchDisp = "Numero de Factura";
	}
	if (request.getParameter("fecha_docto") != null && !request.getParameter("fecha_docto").equals("")){
		appendFilter += " and to_date(to_char(a.fecha_crea,'dd/mm/yyyy'),'dd/mm/yyyy') = to_date('"+request.getParameter("fecha_docto")+"','dd/mm/yyyy')";
    searchOn = "a.fecha_crea";
    searchVal = request.getParameter("fecha_docto");
    searchType = "3";
    searchDisp = "Fecha Documento";
	}

	if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFrom").equals("SVF") && !request.getParameter("searchValTo").equals("SVT"))) && !request.getParameter("searchType").equals("ST")){
    if (searchType.equals("1")){
			appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
    } else if (searchType.equals("2")){
			appendFilter += " and "+searchOn+" = "+searchVal;
    } else if (searchType.equals("3")){
			appendFilter += " and to_date(to_char("+searchOn+",'dd/mm/yyyy'),'dd/mm/yyyy') = to_date('"+searchVal+"','dd/mm/yyyy')";
    }
  } else {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }

	if(appendFilter != null && !appendFilter.equals("")){
		sql = "select a.compania, a.anio, a.codigo, nvl(a.num_factura, ' ') num_factura, a.cliente, to_char(a.fecha_crea, 'dd/mm/yyyy') fecha, a.tipo_transaccion, decode (a.tipo_transaccion, 'C', 'Cargo', 'D', 'Devolucion', 'H', 'Honorario') desc_tipo_transaccion, nvl(b.existe, 'N') existe, nvl(to_char(a.pamd_pac_id), 'null') pac_id, nvl(a.total, 0) total, a.codigo_devol, a.anio_devol, nvl(a.estado_devol, 'A') estado_devol, nvl(a.cliente_alq, 'N') cliente_alq, a.tipo_cliente, nvl(to_char(a.codigo_paciente), ' ') codigo_paciente, nvl(to_char(a.fecha_nacimiento, 'dd/mm/yyyy'), ' ') fecha_nacimiento from tbl_fac_cargo_cliente a, (select compania, anio_cargo, codigo_cargo, tipo_cargo, 'S' existe, codigo from tbl_fac_factura where facturar_a = 'O' and estatus in ('P', 'C') and compania = "+ (String) session.getAttribute("_companyId") +") b where a.compania = " + (String) session.getAttribute("_companyId") + " and a.codigo = b.codigo_cargo(+) and a.compania = b.compania(+) and a.anio = b.anio_cargo(+) and a.num_factura = b.codigo(+) and a.tipo_transaccion = b.tipo_cargo(+)" + appendFilter + " order by a.fecha_crea desc";

		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);

		rowCount = CmnMgr.getCount("select count(*) count from ("+sql+")");
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
document.title = 'Facturacion - '+document.title;

function add(){
	abrir_ventana('../facturacion/reg_cargo_dev_oc.jsp?mode=add&fg=<%=fg%>');
}
 
function view(anio, id, tt){
	abrir_ventana('../facturacion/reg_cargo_dev_oc.jsp?mode=view&codigo='+id+'&anio='+anio+'&fg=<%=fg%>&tipoTransaccion='+tt);
}

function devolver(anio, id, tt){
	abrir_ventana('../facturacion/reg_cargo_dev_oc.jsp?mode=add&codigo='+id+'&anio='+anio+'&fg=<%=fg%>&tipoTransaccion='+tt+'&devol=S');
}

function printCargos(pac_id, admi_secuencia){
	abrir_ventana('../facturacion/print_cargo_dev.jsp?noSecuencia='+admi_secuencia+'&pacId='+pac_id);
}

function printFactura(fac_id){
	abrir_ventana('../facturacion/print_factura_otro_client_det.jsp?factId='+fac_id);
}

function printList(){
  if ('<%=fg%>'=='HON'){
	abrir_ventana('../facturacion/print_list_cargo_dev.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>&fg=<%=fg%>');
	} else if('<%=fg%>'=='PAC'){
		 abrir_ventana('../facturacion/print_list_cargo_dev.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>&fg=<%=fg%>');
	}
}

function facturar(anio, codigo, tipo_tran, cliente_alq, tipo_cliente, num_factura, p_total, p_fecha_nacimiento, p_cod_paciente){
	document.form1.codigo.value = codigo;
	document.form1.anio.value = anio;
	document.form1.tipo_transaccion.value = tipo_tran;
	var clientIdentifier = '<%=ConMgr.getClientIdentifier()%>';

	<%if(fg.equals("www")){%>
	if(tipo_tran=='C'){
		document.form1.codigo_paciente.value = p_cod_paciente;
		document.form1.fecha_nacimiento.value = p_fecha_nacimiento;
		document.form1.tipo_cliente.value = tipo_cliente;
		document.form1.submit();
	} else if(tipo_tran=='D'){
		abrir_ventana('../facturacion/print_devolucion.jsp?codigo='+codigo+'&anio='+anio);
		if(tipo_cliente =='16'){
			if(executeDB('<%=request.getContextPath()%>','call sp_fac_generar_a_cxp(<%=(String) session.getAttribute("_companyId")%>, ' + anio + ', ' + codigo + ', \'' + tipo_tran + '\', \'' + num_factura + '\', \'<%=(String) session.getAttribute("_userName")%>\'' + num_factura + ', ' + p_total + ', \'' + p_fecha_nacimiento + '\', ' + p_cod_paciente +')')){
				var msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);
				if(msg!='') CBMSG.warning(msg);
			} else {
				var msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);
				if(msg!='') CBMSG.warning(msg);
			}
		}
	}
	<%} else {%>
	if(tipo_tran=='C'){
		if(cliente_alq=='N') document.form1.submit();
		else if(cliente_alq=='S'){
			if(tipo_tran=='C'){
				CBMSG.warning('Los cargos hechos a los contraros de alquiler, serán facturados por el depto. de contabilidad, en su efecto se le generará una constancia de que registro el cargo... espere!');
				abrir_ventana('../facturacion/print_comprobante_cargo.jsp?codigo='+codigo+'&anio='+anio);
			} else if(tipo_tran=='D'){
				abrir_ventana('../facturacion/print_devolucion.jsp?codigo='+codigo+'&anio='+anio);
			}
		}
	} else if(tipo_tran=='D'){
		abrir_ventana('../facturacion/print_devolucion.jsp?codigo='+codigo+'&anio='+anio);
	}
	<%}%>
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="FACTURACION - CARGO O DEVOLUCION OTROS CLIENTES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">
<%
if(!fg.equals("HON")){
%>
			<authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel>Registrar Nuevo Cargo</cellbytelabel> ]</a></authtype>
<%
} else {
%>
			<authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel>Registrar Nuevo Honorario</cellbytelabel> ]</a></authtype>
<%
}
%>
		</td>
  </tr>
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
				<%=fb.hidden("fg",fg)%>
				<td width="100%">
					<cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.intBox("codigo","",false,false,false,8)%>
          &nbsp;
					<cellbytelabel>Cliente</cellbytelabel>
					<%=fb.textBox("cliente","",false,false,false,20)%>
          &nbsp;
					<cellbytelabel>A&ntilde;o</cellbytelabel>
					<%=fb.intBox("anio","",false,false,false,5)%>
          &nbsp;
					<cellbytelabel>Num. Factura</cellbytelabel>
					<%=fb.textBox("num_factura","",false,false,false,10)%>
          &nbsp;
					<cellbytelabel>Fecha Doc</cellbytelabel>.
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="nameOfTBox1" value="fecha_docto" />
					<jsp:param name="valueOfTBox1" value="" />
					</jsp:include>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>

			</tr>
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
  <tr>
    <td align="right">
<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"200070")){
%>
			<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype>
<%
//}
%>
			&nbsp;
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
				<%=fb.hidden("fg",fg)%>
        <%=fb.hidden("fecha_docto", request.getParameter("fecha_docto"))%>
        <%=fb.hidden("codigo", request.getParameter("codigo"))%>
        <%=fb.hidden("cliente", request.getParameter("cliente"))%>
        <%=fb.hidden("anio", request.getParameter("anio"))%>
        <%=fb.hidden("num_factura", request.getParameter("num_factura"))%>
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
				<%=fb.hidden("fg",fg)%>
        <%=fb.hidden("fecha_docto", request.getParameter("fecha_docto"))%>
        <%=fb.hidden("codigo", request.getParameter("codigo"))%>
        <%=fb.hidden("cliente", request.getParameter("cliente"))%>
        <%=fb.hidden("anio", request.getParameter("anio"))%>
        <%=fb.hidden("num_factura", request.getParameter("num_factura"))%>
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
		<tr class="TextHeader" align="center">
			<td width="8%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="42%"><cellbytelabel>Cliente</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Fecha Doc</cellbytelabel>.</td>
			<td width="10%"><cellbytelabel>Tipo Transacci&oacute;n</cellbytelabel></td>
      <td width="7%"><cellbytelabel>No. Factura</cellbytelabel></td>
      <td width="5%"><cellbytelabel>Monto Total</cellbytelabel></td>
      <td width="5%"><cellbytelabel>Cod. Devol</cellbytelabel>.</td>
      <td width="5%"><cellbytelabel>A&ntilde;o Devol</cellbytelabel>.</td>
			<td width="5%">&nbsp;</td>
			<td width="5%">&nbsp;</td>
			<td width="5%">&nbsp;</td>
			<td width="5%">&nbsp;</td>
		</tr>
		<% if ((appendFilter == null || appendFilter.trim().equals("")) && al.size() == 0){%>
		<tr class="TextRow01" align="center">
			<td colspan="10">&nbsp; </td>
		</tr>
		<tr class="TextRow01" align="center">
			<td colspan="10"> <font color="#FF0000"> <cellbytelabel>I N T R O D U Z C A</cellbytelabel> &nbsp;&nbsp;&nbsp;&nbsp;<cellbytelabel>P A R &Aacute; M E T R O S</cellbytelabel>&nbsp;&nbsp;&nbsp;&nbsp;D E&nbsp;&nbsp;&nbsp;&nbsp;<cellbytelabel>B &Uacute; S Q U E D A</cellbytelabel></font></td>
		</tr>
		<%}%>
<%
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart()%>
<%=fb.hidden("anio","")%>
<%=fb.hidden("codigo","")%>
<%=fb.hidden("tipo_transaccion","")%>
<%=fb.hidden("codigo_paciente","")%>
<%=fb.hidden("fecha_nacimiento","")%>
<%=fb.hidden("tipo_cliente","")%>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>

		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center">&nbsp;<%=cdo.getColValue("codigo")%></td>
			<td align="left"><%=cdo.getColValue("cliente")%></td>
			<td align="center"><%=cdo.getColValue("fecha")%></td>
			<td align="center"><%=cdo.getColValue("desc_tipo_transaccion")%></td>

      <td align="center"><%=cdo.getColValue("num_factura")%></td>
      <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("total"))%>&nbsp;</td>
      <td align="center"><%=cdo.getColValue("codigo_devol")%></td>
      <td align="center"><%=cdo.getColValue("anio_devol")%></td>
			<td align="center">
			<authtype type='1'><a href="javascript:view(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("codigo")%>,'<%=cdo.getColValue("tipo_transaccion")%>')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><cellbytelabel>Ver</cellbytelabel></a></authtype>
			</td>
			<td align="center">
      <%if(!cdo.getColValue("estado_devol").equals("T") && cdo.getColValue("tipo_transaccion").equals("C")){%>
			<authtype type='51'><a href="javascript:devolver(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("codigo")%>,'<%=cdo.getColValue("tipo_transaccion")%>')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><cellbytelabel>Devolver</cellbytelabel></a></authtype>
      <%}%>
			</td>
			<td align="center">
			<!--<a href="javascript:view(<%=cdo.getColValue("pac_id")%>,<%=cdo.getColValue("codigo")%>,<%=cdo.getColValue("admi_secuencia")%>,'<%=cdo.getColValue("tipo_transaccion")%>')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Ver</a>-->
			<%if(!cdo.getColValue("num_factura").equals("")){%>
      <authtype type='52'><a href="javascript:printFactura('<%=cdo.getColValue("num_factura")%>')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><cellbytelabel>Factura</cellbytelabel></a></authtype>
      <%}%>
			</td>
			<td align="center">
      <%
			if(cdo.getColValue("existe").equals("N") && cdo.getColValue("tipo_transaccion").equals("C")){
			%>
      <authtype type='50'>
      <a href="javascript:facturar('<%=cdo.getColValue("anio")%>','<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("tipo_transaccion")%>','<%=cdo.getColValue("cliente_alq")%>','<%=cdo.getColValue("tipo_cliente")%>','<%=cdo.getColValue("num_factura")%>','<%=cdo.getColValue("total")%>','<%=cdo.getColValue("fecha_nacimiento")%>','<%=cdo.getColValue("codigo_paciente")%>');" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><cellbytelabel>Facturar</cellbytelabel></a>
      </authtype>
      <%
			} else if(cdo.getColValue("existe").equals("N") && cdo.getColValue("tipo_transaccion").equals("D")){
			%>
      <authtype type='53'>
      <a href="javascript:facturar('<%=cdo.getColValue("anio")%>','<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("tipo_transaccion")%>','<%=cdo.getColValue("cliente_alq")%>');" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><cellbytelabel>Devoluci&oacute;n</cellbytelabel></a>
      </authtype>
      <%
			}
			%>
			</td>
		</tr>
<%
}
%>
<%=fb.formEnd(true)%>
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
				<%=fb.hidden("fg",fg)%>
        <%=fb.hidden("fecha_docto", request.getParameter("fecha_docto"))%>
        <%=fb.hidden("codigo", request.getParameter("codigo"))%>
        <%=fb.hidden("cliente", request.getParameter("cliente"))%>
        <%=fb.hidden("anio", request.getParameter("anio"))%>
        <%=fb.hidden("num_factura", request.getParameter("num_factura"))%>
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
				<%=fb.hidden("fg",fg)%>
        <%=fb.hidden("fecha_docto", request.getParameter("fecha_docto"))%>
        <%=fb.hidden("codigo", request.getParameter("codigo"))%>
        <%=fb.hidden("cliente", request.getParameter("cliente"))%>
        <%=fb.hidden("anio", request.getParameter("anio"))%>
        <%=fb.hidden("num_factura", request.getParameter("num_factura"))%>
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
} else {
	Factura fac = new Factura();
	fac.setCodigo(request.getParameter("codigo"));
	fac.setAnio(request.getParameter("anio"));
	fac.setTipoCargo(request.getParameter("tipo_transaccion"));
	fac.setAdmiCodigoPaciente(request.getParameter("codigo_paciente"));
	fac.setAdmiFechaNacimiento(request.getParameter("fecha_nacimiento"));
	fac.setCompania((String) session.getAttribute("_companyId"));
	fac.setFormName("FAC80060");
	fac.setUsuarioCreacion((String) session.getAttribute("_userName"));
	fac.setTipoCliente(request.getParameter("tipo_cliente"));
	System.out.println("tipo_transaccion="+request.getParameter("tipo_transaccion"));
	System.out.println("fecha_nacimiento="+request.getParameter("fecha_nacimiento"));
	System.out.println("tipo_cliente="+request.getParameter("tipo_cliente"));
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	FactMgr.generarFacturaOC(fac);
	String id = FactMgr.getPkColValue("numeroFactura");
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">

function closeWindow()
{
<%
if (FactMgr.getErrCode().equals("1"))
{
%>
	alert('<%=FactMgr.getErrMsg()%>');
	abrir_ventana('../facturacion/print_factura_otro_client_det.jsp?factId=<%=id%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/facturacion/list_cargo_dev_oc.jsp"))
	{
%>
	window.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/facturacion/list_cargo_dev_oc.jsp")%>';
<%
	}
	else
	{
%>
	window.location = '<%=request.getContextPath()%>/facturacion/list_cargo_dev_oc.jsp';
<%
	}

} else throw new Exception(FactMgr.getErrMsg());
%>
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}
%>
