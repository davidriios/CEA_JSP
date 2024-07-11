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
<jsp:useBean id="RecpMgr" scope="page" class="issi.inventory.RecepcionMgr" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
RecpMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sql = new StringBuffer();
StringBuffer appendFilter = new StringBuffer();

String proveedor = request.getParameter("proveedor");
String numero_documento = request.getParameter("numero_documento");
String mes = request.getParameter("mes");
String anio = request.getParameter("anio");
String estado = request.getParameter("estado");
String ruc = request.getParameter("ruc");
String dv = request.getParameter("dv");
String fileName = request.getParameter("fileName");
String cod_tipo_orden_pago = request.getParameter("cod_tipo_orden_pago");
if(proveedor == null) proveedor = "";
if(numero_documento == null) numero_documento = "";
if(mes == null) mes = CmnMgr.getCurrentDate("mm");
if(anio == null) anio = CmnMgr.getCurrentDate("yyyy");
if(estado == null) estado = "";
if(cod_tipo_orden_pago == null) cod_tipo_orden_pago = "";
if(ruc == null) ruc = "";
if(dv == null) dv = "";
if(fileName == null) fileName = "";

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
    appendFilter.append(" and upper(nombre_proveedor) like '%");
		appendFilter.append(IBIZEscapeChars.forSingleQuots(proveedor.toUpperCase()));
		appendFilter.append("%'");
  }

	if (!numero_documento.equals("")){
        appendFilter.append(" and numero_factura = '");
		appendFilter.append(numero_documento);
		appendFilter.append("'");
  }

  if (!mes.trim().equals("") && !anio.trim().equals("")){
    appendFilter.append(" and to_date(to_char(fecha, 'mm/yyyy'), 'mm/yyyy') = to_date('");
		appendFilter.append(mes);
		appendFilter.append("/");
		appendFilter.append(anio);
		appendFilter.append("', 'mm/yyyy')");
	}
	/*
	if (!estado.equals("")){
    appendFilter.append(" and a.estado = '");
		appendFilter.append(estado);
		appendFilter.append("'");
  }
	*/
	if (!ruc.equals("")){
    appendFilter.append(" and ruc = '");
		appendFilter.append(ruc);
		appendFilter.append("'");
  }
	if (!dv.equals("")){
    appendFilter.append(" and dv = ");
		appendFilter.append(dv);
  }

	sql.append("select * from (select b.tipo_persona, decode(b.tipo_persona, 1, 'Natural', 2, 'Juridico', 3, 'Extranjero') tipo_persona_desc, b.ruc, b.digito_verificador dv, b.nombre_proveedor, a.numero_factura, a.fecha_documento fecha, to_char(a.fecha_documento, 'yyyymmdd') fecha_documento, a.cod_concepto, a.compania, a.anio_recepcion, (a.monto_total - a.itbm) + (NVL((SELECT sum(decode (aa.codigo_ajuste, 1, aa.total - aa.itbm, -aa.total + aa.itbm)) FROM tbl_inv_ajustes aa WHERE aa.estado = 'A' and aa.cod_proveedor = b.cod_provedor and aa.anio_doc = a.anio_recepcion and aa.numero_doc = a.numero_documento and aa.compania = a.compania and to_date(to_char(aa.fecha_ajuste, 'mm/yyyy'), 'mm/yyyy') = to_date('");
		sql.append(mes);
		sql.append("/");
		sql.append(anio);
		sql.append("', 'mm/yyyy')");
	sql.append("), 0) + NVL((SELECT sum(-aa.monto + aa.itbm) FROM tbl_inv_devolucion_prov aa WHERE aa.anulado_sino = 'N' and aa.tipo_dev = 'N' and aa.cod_provedor = b.cod_provedor and aa.anio_recepcion = a.anio_recepcion and aa.numero_recepcion = a.numero_documento and aa.compania = a.compania and to_date(to_char(aa.fecha, 'mm/yyyy'), 'mm/yyyy') = to_date('");
		sql.append(mes);
		sql.append("/");
		sql.append(anio);
		sql.append("', 'mm/yyyy')");
	sql.append("), 0) + nvl((SELECT sum(decode(aa.cod_tipo_ajuste,1,aa.monto,-aa.monto)) FROM tbl_cxp_ajuste_saldo_enc aa WHERE aa.estado = 'R' /*and aa.ref_id = to_char (b.cod_provedor)*/ and aa.destino_ajuste in ('P', 'G') and aa.numero_factura = a.numero_factura and aa.ref_id = to_char (a.cod_proveedor) and aa.compania = a.compania and to_date(to_char(aa.fecha, 'mm/yyyy'), 'mm/yyyy') = to_date('");
		sql.append(mes);
		sql.append("/");
		sql.append(anio);
		sql.append("', 'mm/yyyy')");
	sql.append("), 0)) monto_total, a.itbm, to_char(a.cod_proveedor) cod_proveedor, a.cod_concepto || ' - ' || c.descripcion concepto, b.local_internacional, decode(b.local_internacional, 1, 'LOCALES', 2, 'IMPORTACIONES') local_internacional_desc from tbl_inv_recepcion_material a, tbl_com_proveedor b, tbl_con_conceptos c ,tbl_inv_documento_recepcion doc where a.estado = 'R' and a.fre_documento =doc.documento and doc.informe_43='S'  and a.cod_proveedor = b.cod_provedor and a.compania = ");
	sql.append((String) session.getAttribute("_companyId"));
	sql.append(" and a.cod_concepto = c.codigo(+) union all select b.tipo_persona, decode(b.tipo_persona, 1, 'Natural', 2, 'Juridico', 3, 'Extranjero') tipo_persona_desc, b.ruc, b.digito_verificador dv, b.nombre_proveedor, rm.numero_factura, a.fecha_ajuste, to_char(a.fecha_ajuste, 'yyyymmdd') fecha_documento, rm.cod_concepto, a.compania, a.anio_ajuste, decode(a.codigo_ajuste, 1, a.total-a.itbm, -a.total+a.itbm), decode(a.codigo_ajuste, 1, a.itbm, -a.itbm), to_char(a.cod_proveedor) cod_proveedor, rm.cod_concepto || ' - ' || c.descripcion concepto, b.local_internacional, decode(b.local_internacional, 1, 'LOCALES', 2, 'IMPORTACIONES') local_internacional_desc from tbl_inv_ajustes a, tbl_com_proveedor b, tbl_inv_recepcion_material rm, tbl_con_conceptos c, tbl_inv_documento_recepcion doc where a.estado = 'A' and a.compania = ");
	sql.append((String) session.getAttribute("_companyId"));
	sql.append(" and a.cod_proveedor = b.cod_provedor and a.anio_doc = rm.anio_recepcion and a.numero_doc = rm.numero_documento and a.compania = rm.compania and rm.cod_concepto = c.codigo(+) and rm.fre_documento = doc.documento and doc.informe_43 = 'S' and trunc(rm.fecha_documento) < to_date('");
		sql.append(mes);
		sql.append("/");
		sql.append(anio);
		sql.append("', 'mm/yyyy')");
	sql.append(" union all select b.tipo_persona, decode(b.tipo_persona, 1, 'Natural', 2, 'Juridico', 3, 'Extranjero') tipo_persona_desc, b.ruc, b.digito_verificador dv, b.nombre_proveedor, rm.numero_factura, a.fecha, to_char(a.fecha, 'yyyymmdd') fecha_documento, rm.cod_concepto, a.compania, a.anio, -a.monto+a.itbm, -a.itbm, to_char(a.cod_provedor) cod_proveedor, rm.cod_concepto || ' - ' || c.descripcion concepto, b.local_internacional, decode (b.local_internacional, 1, 'LOCALES', 2, 'IMPORTACIONES') local_internacional_desc from tbl_inv_devolucion_prov a, tbl_com_proveedor b, tbl_inv_recepcion_material rm, tbl_con_conceptos c, tbl_inv_documento_recepcion doc where a.anulado_sino = 'N' and a.tipo_dev = 'N' and a.compania = ");
	sql.append((String) session.getAttribute("_companyId"));
	sql.append(" and a.cod_provedor = b.cod_provedor and a.anio_recepcion = rm.anio_recepcion and a.numero_recepcion = rm.numero_documento and a.compania = rm.compania and rm.cod_concepto = c.codigo(+) and rm.fre_documento = doc.documento and doc.informe_43 = 'S' and trunc(rm.fecha_documento) < to_date('");
		sql.append(mes);
		sql.append("/");
		sql.append(anio);
		sql.append("', 'mm/yyyy')");
	sql.append(" union all select b.tipo_persona, decode(b.tipo_persona, 1, 'Natural', 2, 'Juridico', 3, 'Extranjero') tipo_persona_desc, b.ruc, b.digito_verificador dv, b.nombre_proveedor, a.numero_factura, a.fecha, to_char(a.fecha, 'yyyymmdd') fecha_documento, rm.cod_concepto, a.compania, a.anio, decode(a.cod_tipo_ajuste,1,a.monto,-a.monto) as monto, 0 itbm, a.ref_id cod_provedor, rm.cod_concepto || ' - ' || c.descripcion concepto, b.local_internacional, decode (b.local_internacional, 1, 'LOCALES', 2, 'IMPORTACIONES') local_internacional_desc from tbl_cxp_ajuste_saldo_enc a, tbl_com_proveedor b, tbl_inv_recepcion_material rm, tbl_con_conceptos c, tbl_inv_documento_recepcion doc where a.estado = 'R' and a.compania = ");
	sql.append((String) session.getAttribute("_companyId"));
	sql.append(" and a.ref_id = to_char(b.cod_provedor) and a.destino_ajuste in ('P', 'G') and a.numero_factura = rm.numero_factura and a.ref_id = to_char(rm.cod_proveedor) and rm.cod_concepto = c.codigo(+) and rm.fre_documento = doc.documento and doc.informe_43 = 'S' and trunc(rm.fecha_documento) < to_date('");
		sql.append(mes);
		sql.append("/");
		sql.append(anio);
		sql.append("', 'mm/yyyy')");
	sql.append(") where compania is not null ");
	sql.append(appendFilter.toString());
	sql.append(" order by fecha desc");
  al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  
  rowCount = CmnMgr.getCount("SELECT count(*) from ("+sql+")");


	
	
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
}

function ver(numero_documento, anio)
{
}

function editar(numero_documento, anio)
{
}

function printList(){
  abrir_ventana('../cellbyteWV/report_container.jsp?reportName=cxp/rpt_informe_mef.rptdesign&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter.toString())%>&pCtrlHeader=false');
}

function generaTxt(){
	document.main.anio.value = document.search01.anio.value;
	document.main.mes.value = document.search01.mes.value;
	document.main.submit();
}
function showFile(){
var anio=document.main.anio.value;
var mes=document.main.mes.value;
if(mes !='' && anio !=''){showPopWin('../common/generate_file.jsp?fp=FACTPROV&docType=FACTPROV&mes='+mes+'&anio='+anio,winWidth*.75,winHeight*.65,null,null,'');}else alert('Año o mes invalido. Favor Verifique');
}
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
    <td><table width="100%" cellpadding="0" cellspacing="1">
        <tr>
    <td align="right"><authtype type='0'>
        <a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a>
      </authtype>
    </td>
  </tr>
        <tr class="TextFilter">
          <%
					  fb = new FormBean("main","","post");
					%>
          <%=fb.formStart()%> <%=fb.hidden("anio",anio)%> <%=fb.hidden("mes",mes)%> <%=fb.formEnd()%>
          <%
					  fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
          <%=fb.formStart()%> <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
          <td>
          Proveedor: <%=fb.textBox("proveedor",proveedor,false,false,false,30,"text10",null,"")%> 
          No. Factura: <%=fb.textBox("numero_documento",numero_documento,false,false,false,10,"text10",null,"")%> 
          RUC: <%=fb.textBox("ruc",ruc,false,false,false,10,"text10",null,"")%> 
          D.V.: <%=fb.textBox("dv",dv,false,false,false,10,"text10",null,"")%> 
          Estado: <%=fb.select("estado","R=Recibido,A=Anulado",estado, false, false, 0, "text10", "", "", "", "S")%> 
          A&ntilde;o y Mes:<%=fb.textBox("anio",anio,false,false,false,4,null,null,null)%> <%=fb.select("mes","01=Enero,02=Febrero,03=Marzo,04=Abril,05=Mayo,06=Junio,07=Julio,08=Agosto,09=Septiembre,10=Octubre,11=Noviembre,12=Diciembre",mes,false,false,0,"",null,"")%> 
					<%=fb.submit("go","Ir")%> 
					<%=fb.button("txt","Generar TXT",false,false,"text10","","onClick=\"javascript:showFile();\"")%> 
          <%if(!fileName.equals("")){%>
          <a href="../docs/cheques/<%=fileName%>"><font class="BottonTrasl">Ver Archivo</font> </a>
          <%//=fb.button("verTxt","Ver Archivo",false,false,"text10","","onClick=\"javascript:window.open('"+path+"');\"")%> 
          <%}%>
          </td>
          <%=fb.formEnd()%> </tr>
      </table></td>
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
					<%=fb.hidden("proveedor",proveedor)%> 
					<%=fb.hidden("numero_documento",numero_documento)%> 
					<%=fb.hidden("mes",mes)%> 
					<%=fb.hidden("anio",anio)%> <%=fb.hidden("estado",estado)%> 
					<%=fb.hidden("cod_tipo_orden_pago",cod_tipo_orden_pago)%>
					<%=fb.hidden("ruc",ruc)%>
					<%=fb.hidden("dv",dv)%>
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
					<%=fb.hidden("mes",mes)%> 
					<%=fb.hidden("anio",anio)%> 
					<%=fb.hidden("estado",estado)%> 
					<%=fb.hidden("cod_tipo_orden_pago",cod_tipo_orden_pago)%>
          <%=fb.hidden("ruc",ruc)%>
					<%=fb.hidden("dv",dv)%>
          <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
          <%=fb.formEnd()%> </tr>
      </table></td>
  </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableLeftBorder TableRightBorder"><!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
      <table align="center" width="100%" cellpadding="0" cellspacing="1">
        <tr class="TextHeader">
          <td width="6%" align="center"><cellbytelabel>Tipo Persona</cellbytelabel></td>
          <td width="10%" align="center"><cellbytelabel>RUC</cellbytelabel></td>
          <td width="3%" align="center"><cellbytelabel>DV</cellbytelabel></td>
          <td width="26%" align="center"><cellbytelabel>Nombre o Raz&oacute;n Social</cellbytelabel></td>
          <td width="6%" align="center"><cellbytelabel>Factura &frasl; Docto</cellbytelabel>.</td>
          <td width="4%" align="center"><cellbytelabel>Fecha</cellbytelabel></td>
          <td width="26%" align="center"><cellbytelabel>Concepto</cellbytelabel></td>
          <td width="7%"><cellbytelabel>Compras, Bienes, Servicios</cellbytelabel></td>
          <td width="6%"><cellbytelabel>Monto (B&frasl;)</cellbytelabel></td>
          <td width="6%"><cellbytelabel>ITBMS Pagado (B&frasl;)</cellbytelabel></td>
        </tr>
        <%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
        <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
          <td><%=cdo.getColValue("tipo_persona_desc")%></td>
          <td><%=cdo.getColValue("ruc")%></td>
          <td align="center"><%=cdo.getColValue("dv")%></td>
          <td><%=cdo.getColValue("cod_proveedor")%>&nbsp;-&nbsp;<%=cdo.getColValue("nombre_proveedor")%></td>
          <td align="center"><%=cdo.getColValue("numero_factura")%></td>
          <td align="center"><%=cdo.getColValue("fecha_documento")%></td>
          <td align="left"><%=cdo.getColValue("concepto")%></td>
          <td align="center"><%=cdo.getColValue("local_internacional_desc")%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_total"))%>&nbsp;</td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("itbm"))%>&nbsp;</td>
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
					<%=fb.hidden("proveedor",proveedor)%> 
					<%=fb.hidden("numero_documento",numero_documento)%> 
					<%=fb.hidden("mes",mes)%> 
					<%=fb.hidden("anio",anio)%> 
					<%=fb.hidden("estado",estado)%> 
					<%=fb.hidden("cod_tipo_orden_pago",cod_tipo_orden_pago)%>
          <%=fb.hidden("ruc",ruc)%>
					<%=fb.hidden("dv",dv)%>
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
					<%=fb.hidden("mes",mes)%> 
					<%=fb.hidden("anio",anio)%> <%=fb.hidden("estado",estado)%> 
					<%=fb.hidden("cod_tipo_orden_pago",cod_tipo_orden_pago)%>
          <%=fb.hidden("ruc",ruc)%>
					<%=fb.hidden("dv",dv)%>
          <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
          <%=fb.formEnd()%> </tr>
      </table></td>
  </tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
} else {
	CommonDataObject cdo = new CommonDataObject();
	cdo.addColValue("cod_compania", (String) session.getAttribute("_companyId"));
	cdo.addColValue("mes", request.getParameter("mes"));
	cdo.addColValue("anio", request.getParameter("anio"));
	RecpMgr.createFileFactProv(cdo);
	fileName = RecpMgr.getPkColValue("fileName");

%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (RecpMgr.getErrCode().equals("1")){
%>
	alert('Archivo Generado Satisfactoriamente');
	window.location = '<%=request.getContextPath()%>/cxp/informe_mef_list.jsp?mes=<%=request.getParameter("mes")%>&anio=<%=request.getParameter("anio")%>&fileName=<%=IBIZEscapeChars.forURL(fileName)%>';
<%
} else throw new Exception(RecpMgr.getErrMsg());
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
