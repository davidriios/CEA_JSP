<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.HtmlCode"%>
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
==========================================================================================
inv230020  COC - CON ORDEN DE COMPRA
inv800960  SOC - SIN ORDEN DE COMPRA
inv230030  CNE - CONSIGNACION NOTA DE ENTREGA
inv230040  CFP - CONSIGNACION FACTURA DE PROVEEDOR
inv900100  CONSULTA DE FACTURAS POR ORDEN DE COMPRA
inv800970  CONSULTA DE RECEPCION DE MATERIAL
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
StringBuffer sbFilter = new StringBuffer();

String fp = request.getParameter("fp");
String wh = request.getParameter("wh");
String year = request.getParameter("year");
String docNo = request.getParameter("docNo");
String tipoFRecep = request.getParameter("tipoFRecep");
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");
String provCode = request.getParameter("provCode");
String provName = request.getParameter("provName");
String status = request.getParameter("status");
String factNo = request.getParameter("factNo");
String factType = request.getParameter("factType");
String factAmtOpt = request.getParameter("factAmtOpt");
String factAmt = request.getParameter("factAmt");
String expl = request.getParameter("expl");
String ocType = request.getParameter("ocType");
String ocYear = request.getParameter("ocYear");
String ocNo = request.getParameter("ocNo");
String ocFDate = request.getParameter("ocFDate");
String ocTDate = request.getParameter("ocTDate");
String ocAmtOpt = request.getParameter("ocAmtOpt");
String ocAmt = request.getParameter("ocAmt");
String ocStatus = request.getParameter("ocStatus");
String tipo_doc  = request.getParameter("tipo_doc");
String articulo  = request.getParameter("articulo");
String oper = HtmlCode.GREATER_THAN+","+HtmlCode.GREATER_THAN+HtmlCode.EQUAL+"="+HtmlCode.GREATER_EQUAL_THAN+","+HtmlCode.EQUAL+","+HtmlCode.LESS_THAN+HtmlCode.EQUAL+"="+HtmlCode.LESS_EQUAL_THAN+","+HtmlCode.LESS_THAN;

if (fp == null) fp = "";
else if (fp.trim().equalsIgnoreCase("COC")) sbFilter.append(" and a.fre_documento in ('OC')");
else if (fp.trim().equalsIgnoreCase("SOC")) sbFilter.append(" and a.fre_documento in ('FC','FR')");
else if (fp.trim().equalsIgnoreCase("CNE")) sbFilter.append(" and a.fre_documento in ('NE')");
else if (fp.trim().equalsIgnoreCase("CFP")) sbFilter.append(" and a.fre_documento in ('FG')");

if (tipo_doc == null) tipo_doc = "";
if (articulo == null) articulo = "";
if (wh != null && !wh.trim().equals("")) { sbFilter.append(" and a.codigo_almacen = "); sbFilter.append(wh); }
if (year != null && !year.trim().equals("")) { sbFilter.append(" and a.anio_recepcion = "); sbFilter.append(year); }
if (docNo != null && !docNo.trim().equals("")) { sbFilter.append(" and a.numero_documento = "); sbFilter.append(docNo); }
if (tipoFRecep == null || tipoFRecep.trim().equals("")) tipoFRecep = "documento";
if (fDate != null && !fDate.trim().equals("")) { sbFilter.append(" and trunc(a.fecha_"); sbFilter.append(tipoFRecep); sbFilter.append(") >= to_date('"); sbFilter.append(fDate); sbFilter.append("','dd/mm/yyyy')"); }
else fDate = "";
if (tDate != null && !tDate.trim().equals("")) { sbFilter.append(" and trunc(a.fecha_"); sbFilter.append(tipoFRecep); sbFilter.append(") <= to_date('"); sbFilter.append(tDate); sbFilter.append("','dd/mm/yyyy')"); }
else tDate = "";
if (provCode != null && !provCode.trim().equals("")) { sbFilter.append(" and a.cod_proveedor = "); sbFilter.append(provCode); }
if (provName != null && !provName.trim().equals("")) { sbFilter.append(" and b.nombre_proveedor like '%"); sbFilter.append(provName); sbFilter.append("%'"); }
if (status != null && !status.trim().equals("")) { sbFilter.append(" and a.estado = '"); sbFilter.append(status); sbFilter.append("'"); }
if (factNo != null && !factNo.trim().equals("")) { sbFilter.append(" and a.numero_factura like '%"); sbFilter.append(factNo); sbFilter.append("%'"); }
if (factType != null && !factType.trim().equals("")) { sbFilter.append(" and a.tipo_factura = '"); sbFilter.append(factType); sbFilter.append("'"); }
if (factAmtOpt != null && !factAmtOpt.trim().equals("") && factAmt != null && !factAmt.trim().equals("")) {
	String op = factAmtOpt;
	if (op.equals(HtmlCode.GREATER_EQUAL_THAN)) op = ">=";
	else if (op.equals(HtmlCode.LESS_EQUAL_THAN)) op = "<=";
	sbFilter.append(" and a.monto_total"); sbFilter.append(op); sbFilter.append(factAmt);
}
if (expl != null && !expl.trim().equals("")) { sbFilter.append(" and a.explicacion like '%"); sbFilter.append(expl); sbFilter.append("%'"); }
if (ocType != null && !ocType.trim().equals("")) { sbFilter.append(" and a.cf_tipo_com = "); sbFilter.append(ocType); }
if (ocYear != null && !ocYear.trim().equals("")) { sbFilter.append(" and a.cf_anio = "); sbFilter.append(ocYear); }
if (ocNo != null && !ocNo.trim().equals("")) { sbFilter.append(" and a.cf_num_doc = "); sbFilter.append(ocNo); }
if (ocFDate != null && !ocFDate.trim().equals("")) { sbFilter.append(" and trunc(e.fecha_documento) >= to_date('"); sbFilter.append(ocFDate); sbFilter.append("','dd/mm/yyyy')"); }
else ocFDate = "";
if (ocTDate != null && !ocTDate.trim().equals("")) { sbFilter.append(" and trunc(e.fecha_documento) <= to_date('"); sbFilter.append(ocTDate); sbFilter.append("','dd/mm/yyyy')"); }
else ocTDate = "";
if (ocAmtOpt != null && !ocAmtOpt.trim().equals("") && ocAmt != null && !ocAmt.trim().equals("")) {
	String op = ocAmtOpt;
	if (op.equals(HtmlCode.GREATER_EQUAL_THAN)) op = ">=";
	else if (op.equals(HtmlCode.LESS_EQUAL_THAN)) op = "<=";
	sbFilter.append(" and e.monto_total"); sbFilter.append(op); sbFilter.append(ocAmt);
}
if (ocStatus != null && !ocStatus.trim().equals("")) { sbFilter.append(" and e.status = '"); sbFilter.append(ocStatus); sbFilter.append("'"); }
if (!tipo_doc.trim().equals("") && tipo_doc.trim().equals("FC")) { sbFilter.append(" and decode(fre_documento,'OC',decode(e.tipo_pago,1,'FC','FR'),fre_documento) = '"); sbFilter.append(tipo_doc); sbFilter.append("'"); }
else if (!tipo_doc.trim().equals("")) { sbFilter.append(" and fre_documento = '"); sbFilter.append(tipo_doc); sbFilter.append("'"); }
if (!articulo.trim().equals("")) { sbFilter.append(" and exists (select null from tbl_inv_detalle_recepcion x where x.anio_recepcion = a.anio_recepcion and x.numero_documento = a.numero_documento and x.compania = a.compania and x.cod_articulo = "); sbFilter.append(articulo); sbFilter.append(")"); }

if (request.getMethod().equalsIgnoreCase("GET")) {
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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

	if (request.getParameter("wh") != null) {
		sbSql.append("select a.anio_recepcion, a.numero_documento, a.estado, decode(a.estado,'A','ANULADO','R','RECIBIDO',a.estado) as desc_estado, to_char(nvl(a.fecha_documento,sysdate),'dd/mm/yyyy') as fecha_documento, decode(a.cod_proveedor,null,' ',a.cod_proveedor) as cod_proveedor, decode(a.codigo_almacen,null,' ',a.codigo_almacen) as codigo_almacen, nvl(a.explicacion,' ') as explicacion, nvl(b.nombre_proveedor,' ') as nombre_proveedor, nvl(c.descripcion,' ') as almacen_desc, a.fre_documento, a.numero_factura, a.tipo_factura, decode(a.tipo_factura,'I','INVENTARIO','S','SERVICIOS',a.tipo_factura) as tipo_factura_desc, decode(a.monto_total,null,' ',to_char(a.monto_total,'999,999,990.00')) as monto_total, a.monto_total as monto_tot, decode(a.cf_anio,null,' ',a.cf_anio) as cf_anio, decode(a.cf_num_doc,null,' ',a.cf_num_doc) as cf_num_doc, decode(a.cf_tipo_com,null,' ',a.cf_tipo_com) as cf_tipo_com, nvl(d.descripcion,' ') as tipoCompromiso, nvl(to_char(e.fecha_documento,'dd/mm/yyyy'),' ') as fechaOC, decode(e.monto_total,null,' ',to_char(e.monto_total,'999,999,990.00')) as montoOC, nvl(e.status,' ') as statusOC, decode(e.status,null,' ','A','APROBADO','N','N','P','PENDIENTE','R','PROCESADO','T','TRAMITE',e.status) as statusOCDesc from tbl_inv_recepcion_material a, tbl_com_proveedor b, tbl_inv_almacen c, tbl_com_tipo_compromiso d, tbl_com_comp_formales e where a.cod_proveedor = b.cod_provedor(+) and a.codigo_almacen = c.codigo_almacen(+) and a.compania = c.compania(+) and a.cf_tipo_com = d.tipo_com(+) and a.cf_anio = e.anio(+) and a.cf_tipo_com = e.tipo_compromiso(+) and a.cf_num_doc = e.num_doc(+) and a.compania = e.compania(+) and a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(sbFilter);
		sbSql.append(" order by a.anio_recepcion desc, a.fecha_creacion desc, a.numero_documento desc");

		StringBuffer sbTmp = new StringBuffer();
		sbTmp.append("select * from (select rownum as rn, a.* from (");
		sbTmp.append(sbSql);
		sbTmp.append(") a) where rn between ");
		sbTmp.append(previousVal);
		sbTmp.append(" and ");
		sbTmp.append(nextVal);
		al = SQLMgr.getDataList(sbTmp.toString());

		sbTmp = new StringBuffer();
		sbTmp.append("select count(*) from tbl_inv_recepcion_material a, tbl_com_proveedor b, tbl_inv_almacen c, tbl_com_tipo_compromiso d, tbl_com_comp_formales e where a.cod_proveedor = b.cod_provedor(+) and a.codigo_almacen = c.codigo_almacen(+) and a.compania = c.compania(+) and a.cf_tipo_com = d.tipo_com(+) and a.cf_anio = e.anio(+) and a.cf_tipo_com = e.tipo_compromiso(+) and a.cf_num_doc = e.num_doc(+) and a.compania = e.compania(+) and a.compania = ");
		sbTmp.append(session.getAttribute("_companyId"));
		sbTmp.append(sbFilter);
		rowCount = CmnMgr.getCount(sbTmp.toString());
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
document.title = 'Inventario - '+document.title;

function add()
{
<%if (fp.trim().equalsIgnoreCase("COC")){%>
	abrir_ventana('../inventario/reg_recepcion_con_oc.jsp');
<%} else if (fp.trim().equalsIgnoreCase("SOC")){%>
	abrir_ventana('../inventario/reg_recepcion_sin_oc.jsp');
<%} else if (fp.trim().equalsIgnoreCase("CNE")){%>
	abrir_ventana('../inventario/reg_recepcion_nentrega.jsp');
<%} else if (fp.trim().equalsIgnoreCase("CFP")){%>
	abrir_ventana('../inventario/reg_recepcion_fact_prov.jsp');
<%}%>
}

function view(docto,ocType,anio,id,facType)
{

<%if (fp.trim().equalsIgnoreCase("COC")){%>
	abrir_ventana('../inventario/reg_recepcion_con_oc.jsp?mode=view&id='+id+'&anio='+anio);
<%} else if (fp.trim().equalsIgnoreCase("SOC")){%>
	abrir_ventana('../inventario/reg_recepcion_sin_oc.jsp?mode=view&id='+id+'&anio='+anio);
<%} else if (fp.trim().equalsIgnoreCase("CNE")){%>
	abrir_ventana('../inventario/reg_recepcion_nentrega.jsp?mode=view&id='+id+'&anio='+anio);
<%} else if (fp.trim().equalsIgnoreCase("CFP")){%>
	abrir_ventana('../inventario/reg_recepcion_fact_prov.jsp?mode=view&id='+id+'&anio='+anio);
<%} else if (fp.trim().equals("")){%>

	if(ocType.trim()=='' && (docto == 'FC' || docto == 'FR')&&facType=='I')abrir_ventana('../inventario/reg_recepcion_sin_oc.jsp?mode=view&id='+id+'&anio='+anio);
	else if(ocType.trim()!='' && (docto == 'FC' || docto == 'OC')&&facType=='I') abrir_ventana('../inventario/reg_recepcion_con_oc.jsp?mode=view&id='+id+'&anio='+anio);
	else if(ocType.trim()=='' && (docto == 'NE')&&facType=='I') abrir_ventana('../inventario/reg_recepcion_nentrega.jsp?mode=view&id='+id+'&anio='+anio);
	else if(ocType.trim()=='' && (docto == 'FG')&&facType=='I') abrir_ventana('../inventario/reg_recepcion_fact_prov.jsp?mode=view&id='+id+'&anio='+anio);
	else if(facType=='S')abrir_ventana('../cxp/fact_prov.jsp?mode=view&numero_documento='+id+'&anio='+anio);
<%}%>
}

function viewOC(ocType,anio,id)
{
	if(ocType.trim()=='1')abrir_ventana('../compras/reg_orden_compra_normal.jsp?mode=view&id='+id+'&anio='+anio);
	else if(ocType.trim()=='2')abrir_ventana('../compras/reg_orden_compra_esp.jsp?mode=view&id='+id+'&anio='+anio);
	else if(ocType.trim()=='3')abrir_ventana('../compras/reg_orden_compra_parcial.jsp?mode=view&id='+id+'&anio='+anio);
}

function viewFact(year,docNo,k)
{
	var factNo = eval('document.recepcion.noFact'+k).value;
	abrir_ventana('../inventario/list_detalle_factura.jsp?year='+year+'&docNo='+docNo+'&factNo='+factNo);
}

function printList(){abrir_ventana('../inventario/print_list_recepcion.jsp?fp=<%=fp%>&appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>&estado=<%=status%>');}

function validateSearch()
{
	if(!isValidAmtOper('factAmt'))
	{
		alert('Por favor ingrese la operación y el monto de la Factura!');
		return false;
	}
	else if(!isValidAmtOper('ocAmt'))
	{
		alert('Por faovr ingrese la operación y el monto de la Orden de Compra!');
		return false;
	}
	return true;
}

function isValidAmtOper()
{
	if(eval('document.main.'+objName+'Opt').value==''&&eval('document.main.'+objName).value.trim()!='')return false;
	else if(eval('document.main.'+objName+'Opt').value!=''&&eval('document.main.'+objName).value.trim()=='')return false;
	else return true;
}

function getProv()
{
	abrir_ventana('../common/search_proveedor.jsp?fp=consulta_recepcion');
}
function editFact(year,docNo,k){
	var userMod = '<%=(String) session.getAttribute("_userName")%>';
	var proveedor = eval('document.recepcion.cod_proveedor'+k).value;
	var factNo = eval('document.recepcion.noFact'+k).value;
	var montoFact = eval('document.recepcion.montoFact'+k).value;
	var saldo = getDBData('<%=request.getContextPath()%>','nvl(getSaldoFactPRov(<%=(String) session.getAttribute("_companyId")%>,'+proveedor+', \''+factNo+'\',2),0)','dual','');
	if(parseFloat(montoFact)!=parseFloat(saldo))alert('No puede modificar la factura. La Factura Tiene Transacciones Realizadas. (Revise ajustes, devolucion ó pagos) ');
	else{
		if(confirm('¿Esta seguro de MODIFICAR el no. de está factura?')){
			var factura = prompt("No. Factura:",""+eval('document.recepcion.noFact'+k).value);
			if(factura != null && factura.trim() != '' && factura.trim() != '0' && factura.trim() != '00' && factura.trim() != factNo){
				if(hasDBData('<%=request.getContextPath()%>','tbl_inv_recepcion_material','compania = <%=session.getAttribute("_companyId")%> and cod_proveedor = \''+proveedor+'\' and numero_factura = \''+factura+'\' and estado = \'R\''))alert('La Factura ya fue registrada al Proveedor. Verifique!');
				else{
					if(executeDB('<%=request.getContextPath()%>','update tbl_inv_recepcion_material set  numero_factura = \''+factura+'\' , usuario_mod =\''+userMod+'\',fecha_mod = sysdate  where compania = <%=session.getAttribute("_companyId")%> and anio_recepcion = '+year+'  and numero_documento = '+docNo)){
						eval('document.recepcion.noFact'+k).value = factura;
						eval('document.recepcion.numero_factura'+k).value = factura;
						alert('Factura Modificada');
					}else alert('Error al modificar la Factura '+factNo);
				}
			}
		}
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - RECEPCION MAT. Y EQUIPOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="1">
		<%fb = new FormBean("main",request.getContextPath()+"/common/urlRedirect.jsp");%>
		<%//fb.appendJsValidation("if(!validateSearch())return false;");%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("fp",fp)%>
		<tr class="TextFilter">
			<td colspan="2">
				Almac&eacute;n
				<%=fb.select(ConMgr.getConnection(),"select codigo_almacen as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania="+(String) session.getAttribute("_companyId"),"wh",wh,"T")%>
			</td>
			<td>
				Estado
				<%=fb.select("status","A=ANULADO,R=RECIBIDO",status,false,false,0,"T")%>
			</td>
			<td>
				Fecha<%=fb.select("tipoFRecep","documento=DOCUMENTO,creacion=REGISTRO, anulacion=ANULACION",tipoFRecep,false,false,0,"Text10",null,null)%>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2"/>
				<jsp:param name="clearOption" value="true"/>
				<jsp:param name="nameOfTBox1" value="fDate"/>
				<jsp:param name="valueOfTBox1" value=""/>
				<jsp:param name="nameOfTBox2" value="tDate"/>
				<jsp:param name="valueOfTBox2" value=""/>
				</jsp:include>
			</td>
		</tr>
		<tr class="TextFilter">
			<td>
				A&ntilde;o
				<%=fb.intBox("year","",false,false,false,4)%>
			</td>
			<td>
				No. Recep.
				<%=fb.intBox("docNo","",false,false,false,6)%>
			</td>
			<td colspan="2">
				Proveedor
				<%=fb.intBox("provCode","",false,false,false,5)%>
				<%=fb.textBox("provName","",false,false,false,50)%>
				<%=fb.button("searchProv","...",false,false,null,null,"onClick=\"javascript:getProv()\"")%>
			</td>
		</tr>
		<tr class="TextFilter">
			<td width="16%">
				Tipo Fact.
				<%=fb.select("factType","I=INVENTARIO,S=SERVICIOS",factType,false,false,0,"T")%>
			</td>
			<td width="16%">
				No. Fact.
				<%=fb.textBox("factNo","",false,false,false,15)%>
			</td>
			<td width="19%">
				Monto Fact.
				<%=fb.select("factAmtOpt",oper,factAmtOpt,false,false,0," ")%>
				<%=fb.decBox("factAmt","",false,false,false,10)%>
			</td>
			<td width="49%">
				Explicaci&oacute;n
				<%=fb.textBox("expl","",false,false,false,40)%>
			</td>
		</tr>
		<tr class="TextFilter">
			<td>
				A&ntilde;o OC
				<%=fb.intBox("ocYear","",false,false,false,4)%>
			</td>
			<td>
				No. OC
				<%=fb.intBox("ocNo","",false,false,false,6)%>
			</td>
			<td>
				Monto OC
				<%=fb.select("ocAmtOpt",oper,ocAmtOpt,false,false,0," ")%>
				<%=fb.decBox("ocAmt","",false,false,false,10)%>
			</td>
			<td>
				Fecha OC
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2"/>
				<jsp:param name="clearOption" value="true"/>
				<jsp:param name="nameOfTBox1" value="ocFDate"/>
				<jsp:param name="valueOfTBox1" value=""/>
				<jsp:param name="nameOfTBox2" value="ocTDate"/>
				<jsp:param name="valueOfTBox2" value=""/>
				</jsp:include>
			</td>
		</tr>
		<tr class="TextFilter">
			<td colspan="2">
				Tipo OC
				<%=fb.select(ConMgr.getConnection(),"select tipo_com, tipo_com||' '||descripcion from tbl_com_tipo_compromiso order by tipo_com","ocType",ocType,false,false,0,"T")%>
			</td>
			<td colspan="2">
				Estado OC
				<%=fb.select("ocStatus","T=TRAMITE,A=APROBADO,P=PENDIENTE,R=PROCESADO",ocStatus,false,false,0,"T")%><!--,N-->
				&nbsp;&nbsp;Tipo Doc:<%=fb.select("tipo_doc","FC=FACTURA CONTADO,OC=ORDEN DE COMPRA,FG=FACTURAS CONSIGNACION,NE=NOTA ENTREGA,FR=FACTURAS CREDITOS",tipo_doc,false,false,0,"S")%>
				&nbsp;&nbsp;Articulo:<%=fb.intBox("articulo",articulo,false,false,false,4)%>

				<%=fb.submit("go","Ir")%>
			</td>
		</tr>
		<%=fb.formEnd(true)%>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</td>
</tr>
<tr>
	<td align="right">&nbsp;
	<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>
<%
//}
%>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp","","onSubmit=\"javascript:return(replacePercent(this.searchVal))\"");%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("wh",wh)%>
<%=fb.hidden("year",year)%>
<%=fb.hidden("docNo",docNo)%>
<%=fb.hidden("tipoFRecep",tipoFRecep)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("provCode",provCode)%>
<%=fb.hidden("provName",provName)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("factNo",factNo)%>
<%=fb.hidden("factType",factType)%>
<%=fb.hidden("factAmtOpt",factAmtOpt)%>
<%=fb.hidden("factAmt",factAmt)%>
<%=fb.hidden("expl",expl)%>
<%=fb.hidden("ocType",ocType)%>
<%=fb.hidden("ocYear",ocYear)%>
<%=fb.hidden("ocNo",ocNo)%>
<%=fb.hidden("ocFDate",ocFDate)%>
<%=fb.hidden("ocTDate",ocTDate)%>
<%=fb.hidden("ocAmtOpt",ocAmtOpt)%>
<%=fb.hidden("ocAmt",ocAmt)%>
<%=fb.hidden("ocStatus",ocStatus)%>
<%=fb.hidden("articulo",articulo)%>
<%=fb.hidden("tipo_doc",tipo_doc)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp","","onSubmit=\"javascript:return(replacePercent(this.searchVal))\"");%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("wh",wh)%>
<%=fb.hidden("year",year)%>
<%=fb.hidden("docNo",docNo)%>
<%=fb.hidden("tipoFRecep",tipoFRecep)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("provCode",provCode)%>
<%=fb.hidden("provName",provName)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("factNo",factNo)%>
<%=fb.hidden("factType",factType)%>
<%=fb.hidden("factAmtOpt",factAmtOpt)%>
<%=fb.hidden("factAmt",factAmt)%>
<%=fb.hidden("expl",expl)%>
<%=fb.hidden("ocType",ocType)%>
<%=fb.hidden("ocYear",ocYear)%>
<%=fb.hidden("ocNo",ocNo)%>
<%=fb.hidden("ocFDate",ocFDate)%>
<%=fb.hidden("ocTDate",ocTDate)%>
<%=fb.hidden("ocAmtOpt",ocAmtOpt)%>
<%=fb.hidden("ocAmt",ocAmt)%>
<%=fb.hidden("ocStatus",ocStatus)%>
<%=fb.hidden("articulo",articulo)%>
<%=fb.hidden("tipo_doc",tipo_doc)%>
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
<%fb = new FormBean("recepcion",request.getContextPath()+request.getServletPath(),"");%>
<%=fb.formStart(true)%>

		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="21%">Almac&eacute;n</td>
			<td width="3%">A&ntilde;o</td>
			<td width="5%">No. Recep.</td>
			<td width="6%">Fecha Recep.</td>
			<td colspan="2">Proveedor</td>
			<td width="12%">No. Fact.</td>
			<td width="8%">Tipo. Fact.</td>
			<td width="7%">Monto Fact.</td>
			<td width="6%">Estado</td>
			<td width="3%">&nbsp;</td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("noFact"+i,cdo.getColValue("numero_factura"))%>
		<%=fb.hidden("cod_proveedor"+i,cdo.getColValue("cod_proveedor"))%>
		<%=fb.hidden("montoFact"+i,cdo.getColValue("monto_tot"))%>

		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="left">[<%=cdo.getColValue("codigo_almacen")%>] <%=cdo.getColValue("almacen_desc")%></td>
			<td align="center"><%=cdo.getColValue("anio_recepcion")%></td>
			<td align="center"><%=cdo.getColValue("numero_documento")%></td>
			<td align="center"><%=cdo.getColValue("fecha_documento")%></td>
			<td align="left" colspan="2">[<%=cdo.getColValue("cod_proveedor")%>] <%=cdo.getColValue("nombre_proveedor")%></td>
			<td align="left" style="cursor:pointer">
			<authtype type='1'> <a href="javascript:viewFact(<%=cdo.getColValue("anio_recepcion")%>,<%=cdo.getColValue("numero_documento")%>,<%=i%>)" > <%=fb.textBox("numero_factura"+i,cdo.getColValue("numero_factura"),false,false,true,5)%></a> </authtype> &nbsp;
			<authtype type='52'><a href="javascript:editFact(<%=cdo.getColValue("anio_recepcion")%>,<%=cdo.getColValue("numero_documento")%>,<%=i%>)"> [ Editar ] </a> </authtype>
			</td>
			<td align="center"><%=cdo.getColValue("tipo_factura_desc")%></td>
			<td align="right"><%=cdo.getColValue("monto_total")%>&nbsp;</td>
			<td align="center"><%=cdo.getColValue("desc_estado")%></td>
			<td align="center" rowspan="2">
<authtype type='1'><a href="javascript:view('<%=cdo.getColValue("fre_documento")%>','<%=cdo.getColValue("cf_tipo_com")%>',<%=cdo.getColValue("anio_recepcion")%>,<%=cdo.getColValue("numero_documento")%>,'<%=cdo.getColValue("tipo_factura")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Ver</a></authtype></td>
		</tr>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td colspan="5" width="54%" style="cursor:pointer"  onClick="javascript:viewOC('<%=cdo.getColValue("cf_tipo_com")%>','<%=cdo.getColValue("cf_anio")%>','<%=cdo.getColValue("cf_num_doc")%>')">
				<table border="0" cellspacing="1" cellpadding="1" width="100%">
				<tr>
					<td width="10%">Tipo OC:</td>
					<td width="45%"><%=(cdo.getColValue("cf_tipo_com").trim().equals(""))?"":"["+cdo.getColValue("cf_tipo_com")+"]"%> <%=cdo.getColValue("tipoCompromiso")%></td>
					<td width="8%">A&ntilde;o:</td>
					<td width="17%"><%=cdo.getColValue("cf_anio")%></td>
					<td width="10%">No. OC:</td>
					<td width="10%"><%=cdo.getColValue("cf_num_doc")%></td>
				</tr>
				<tr>
					<td>Fecha OC:</td>
					<td><%=cdo.getColValue("fechaOC")%></td>
					<td>Estado:</td>
					<td><%=cdo.getColValue("statusOCDesc")%></td>
					<td>Monto OC:</td>
					<td align="right"><%=cdo.getColValue("montoOC")%>&nbsp;</td>
				</tr>
				</table>
			</td>
			<td colspan="5" width="41%"><%=cdo.getColValue("explicacion")%></td>
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
<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp","","onSubmit=\"javascript:return(replacePercent(this.searchVal))\"");%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("wh",wh)%>
<%=fb.hidden("year",year)%>
<%=fb.hidden("docNo",docNo)%>
<%=fb.hidden("tipoFRecep",tipoFRecep)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("provCode",provCode)%>
<%=fb.hidden("provName",provName)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("factNo",factNo)%>
<%=fb.hidden("factType",factType)%>
<%=fb.hidden("factAmtOpt",factAmtOpt)%>
<%=fb.hidden("factAmt",factAmt)%>
<%=fb.hidden("expl",expl)%>
<%=fb.hidden("ocType",ocType)%>
<%=fb.hidden("ocYear",ocYear)%>
<%=fb.hidden("ocNo",ocNo)%>
<%=fb.hidden("ocFDate",ocFDate)%>
<%=fb.hidden("ocTDate",ocTDate)%>
<%=fb.hidden("ocAmtOpt",ocAmtOpt)%>
<%=fb.hidden("ocAmt",ocAmt)%>
<%=fb.hidden("ocStatus",ocStatus)%>
<%=fb.hidden("articulo",articulo)%>
<%=fb.hidden("tipo_doc",tipo_doc)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp","","onSubmit=\"javascript:return(replacePercent(this.searchVal))\"");%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("wh",wh)%>
<%=fb.hidden("year",year)%>
<%=fb.hidden("docNo",docNo)%>
<%=fb.hidden("tipoFRecep",tipoFRecep)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("provCode",provCode)%>
<%=fb.hidden("provName",provName)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("factNo",factNo)%>
<%=fb.hidden("factType",factType)%>
<%=fb.hidden("factAmtOpt",factAmtOpt)%>
<%=fb.hidden("factAmt",factAmt)%>
<%=fb.hidden("expl",expl)%>
<%=fb.hidden("ocType",ocType)%>
<%=fb.hidden("ocYear",ocYear)%>
<%=fb.hidden("ocNo",ocNo)%>
<%=fb.hidden("ocFDate",ocFDate)%>
<%=fb.hidden("ocTDate",ocTDate)%>
<%=fb.hidden("ocAmtOpt",ocAmtOpt)%>
<%=fb.hidden("ocAmt",ocAmt)%>
<%=fb.hidden("ocStatus",ocStatus)%>
<%=fb.hidden("articulo",articulo)%>
<%=fb.hidden("tipo_doc",tipo_doc)%>
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