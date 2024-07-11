<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.caja.TransaccionPago"%>
<%@ page import="issi.caja.DetallePago"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iDoc" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vDoc" scope="session" class="java.util.Vector"/>
<%
/**
==============================================================================
==============================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String mode = request.getParameter("mode");
String tipoCliente = request.getParameter("tipoCliente");
String codigo = request.getParameter("codigo");
String compania = request.getParameter("compania");
String anio = request.getParameter("anio");
String referTo = request.getParameter("referTo");
String refId = request.getParameter("refId");
String refType = request.getParameter("refType");
String flag = request.getParameter("flag");
String order = request.getParameter("order");
String factXTipoClte = "S";
String key = "";
int lastLineNo = 0;
String docType = request.getParameter("docType");
String docTypeOpt = "F=FACTURA";
if (docType == null) docType = "F";
String toDate = CmnMgr.getCurrentDate("dd/mm/yyyy");

String fDate = request.getParameter("fDate")==null?"":request.getParameter("fDate");
String tDate = request.getParameter("tDate")==null?"":request.getParameter("tDate");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (fg == null) fg = "";
if (flag == null) flag = "";
if (order == null) order = "";

if (mode == null) mode = "add";
if (request.getParameter("lastLineNo") != null && !request.getParameter("lastLineNo").trim().equals("")) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));

// incomplete implementation
boolean applyOrderBy = true;

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

	String docNo = request.getParameter("docNo");
	String docFiscal = request.getParameter("docFiscal");
	String aNombre = request.getParameter("aNombre");
	if (docNo == null) docNo = "";
	if (docFiscal == null) docFiscal = "";
	if (aNombre == null) aNombre = "";
	if (!docNo.trim().equals("")) { if (docType.equalsIgnoreCase("D")) sbFilter.append(" and a.secuencia like '%"); else sbFilter.append(" and a.codigo like '%"); sbFilter.append(docNo.toUpperCase()); sbFilter.append("%'"); }
	if (!docFiscal.trim().equals("")) { if (docType.equalsIgnoreCase("F"))  sbFilter.append(" and nvl((select nvl(s.codigo_dgi,'-') from tbl_fac_dgi_documents s where s.codigo = a.codigo and s.compania = a.compania and s.tipo_docto = 'FACT' and rownum=1),' ') like '%"); sbFilter.append(docFiscal.toUpperCase()); sbFilter.append("%'"); }
	if (!aNombre.trim().equals("")) {

		/*if (tipoCliente.equalsIgnoreCase("O")) sbFilter.append(" and upper(b.cliente) like '%");
		else sbFilter.append(" and upper(b.nombre_paciente) like '%");
		sbFilter.append(aNombre.toUpperCase()); sbFilter.append("%'");*/
		
		if (tipoCliente.equalsIgnoreCase("O")) {
		
			sbFilter.append(" and upper(a.nombre_cliente) like '%");
			sbFilter.append(aNombre.toUpperCase());
			sbFilter.append("%'");
		
		} else {
		
			sbFilter.append(" and exists (select null from vw_adm_paciente where pac_id = a.pac_id and upper(nombre_paciente) like '%");
			sbFilter.append(aNombre.toUpperCase());
			sbFilter.append("%')");
		
		}

	}
	
	String appendFilter = "";
	if (request.getParameter("fDate") != null && !request.getParameter("fDate").trim().equals("") && request.getParameter("tDate") != null && !request.getParameter("tDate").trim().equals("")){
	    String dateField = "a.fecha";
		
		if (tipoCliente.equalsIgnoreCase("P") && docType.equalsIgnoreCase("R")) dateField = "a.fecha_creacion";
		else if (tipoCliente.equalsIgnoreCase("P") && docType.equalsIgnoreCase("D")) dateField = "a.fecha_ingreso";
		
		appendFilter = " and trunc("+dateField+") between to_date('"+request.getParameter("fDate")+"','dd/mm/yyyy') and to_date('"+request.getParameter("tDate")+"','dd/mm/yyyy') ";
		fDate = request.getParameter("fDate"); 
		tDate = request.getParameter("tDate"); 
    }
	

	if (fp.equalsIgnoreCase("recibos"))
	{
		if (tipoCliente.equalsIgnoreCase("E"))
		{
			sbSql = new StringBuffer();
			sbSql.append("select a.fecha as fecha_ord ,a.facturar_a as ref_type, 'F' as doc_type, a.codigo as doc_no, a.compania, 'EMPR' as ref_to, ''||a.cod_empresa as cliente, a.pac_id, a.admi_secuencia as admision, a.cod_empresa, a.codigo as factura, null as remanente, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.grang_total as monto_total, (select fn_cja_saldo_fact(a.facturar_a,a.compania,a.codigo,a.grang_total) from dual) as monto_deuda, (select estado from tbl_adm_admision where pac_id = a.pac_id and secuencia = a.admi_secuencia) as estado_adm, (select categoria from tbl_adm_admision where pac_id = a.pac_id and secuencia = a.admi_secuencia) as categoria_adm, (select (select descripcion from tbl_adm_categoria_admision where codigo = z.categoria) from tbl_adm_admision z where z.pac_id = a.pac_id and z.secuencia = a.admi_secuencia) as categoria_adm_desc, (select (select nombre_corto from tbl_adm_categoria_admision where codigo = z.categoria) from tbl_adm_admision z where z.pac_id = a.pac_id and z.secuencia = a.admi_secuencia) as categoria_adm_corto, (select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id) as nombre, ' ' as ubicacion ");
			sbSql.append(",  nvl((select nvl(s.codigo_dgi,'-') from tbl_fac_dgi_documents s where s.codigo = a.codigo and s.compania = a.compania and s.tipo_docto = 'FACT' and rownum=1),' ') dgiDocto ");
			sbSql.append(",nvl(a.comentario,'-') sInicial from tbl_fac_factura a,(select compania, codigo, (select fn_cja_saldo_fact(facturar_a,compania,codigo,grang_total) from dual) as saldocaja from tbl_fac_factura xx where compania="+compania+" and ( exists ( select null from tbl_adm_empresa em where nvl(em.codigo_resp,em.codigo)  = "+refId+"  and em.codigo=xx.cod_empresa ) or cod_empresa="+refId+"  ) and facturar_a='"+tipoCliente+"' and estatus <> 'A') c where  a.compania=c.compania and a.codigo=c.codigo and a.compania = "); 
			sbSql.append(compania);
			sbSql.append(" and ( exists ( select null from tbl_adm_empresa em where nvl(em.codigo_resp,em.codigo) =");
			sbSql.append(refId);
			sbSql.append(" and em.codigo=a.cod_empresa ) or cod_empresa=");
			sbSql.append(refId);
			sbSql.append(" ) ");			
			sbSql.append(" and a.facturar_a = '");
			sbSql.append(tipoCliente);
			sbSql.append("' and a.estatus <> 'A'");
			sbSql.append(sbFilter);
			sbSql.append(appendFilter);
			sbSql.append(" and c.saldocaja> 0");
			
			//if (applyOrderBy) sbSql.append(" order by a.fecha desc ");
			
		}//tipoCliente = E
		else if (tipoCliente.equalsIgnoreCase("P"))
		{
			docTypeOpt = "F=FACTURA,D=ADMISION";//Se quita remante. ,R=REMANENTE
			if (docType.equalsIgnoreCase("F"))
			{
				sbSql = new StringBuffer();
				sbSql.append("select a.fecha as fecha_ord ,a.facturar_a as ref_type, 'F' as doc_type, a.codigo as doc_no, a.compania, 'PAC' as ref_to, ''||a.pac_id as cliente, a.pac_id, a.admi_secuencia as admision, a.cod_empresa, a.codigo as factura, null as remanente, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.grang_total as monto_total, (select fn_cja_saldo_fact(a.facturar_a,a.compania,a.codigo,a.grang_total) from dual) as monto_deuda, (select estado from tbl_adm_admision where pac_id = a.pac_id and secuencia = a.admi_secuencia) as estado_adm, (select categoria from tbl_adm_admision where pac_id = a.pac_id and secuencia = a.admi_secuencia) as categoria_adm, (select (select descripcion from tbl_adm_categoria_admision where codigo = z.categoria) from tbl_adm_admision z where z.pac_id = a.pac_id and z.secuencia = a.admi_secuencia) as categoria_adm_desc, (select (select nombre_corto from tbl_adm_categoria_admision where codigo = z.categoria) from tbl_adm_admision z where z.pac_id = a.pac_id and z.secuencia = a.admi_secuencia) as categoria_adm_corto, (select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id) as nombre, a.ubicacion ");
				sbSql.append(",  nvl((select nvl(s.codigo_dgi,'-') from tbl_fac_dgi_documents s where s.codigo = a.codigo and s.compania = a.compania and s.tipo_docto /*_ref*/ = 'FACT' and rownum=1),' ') dgiDocto ");
				sbSql.append(",nvl(a.comentario,'-') sInicial from tbl_fac_factura a where a.compania = ");
				sbSql.append(compania);
				sbSql.append(" and a.pac_id = ");
				sbSql.append(refId);
				sbSql.append(" and a.facturar_a = '");
				sbSql.append(tipoCliente);
				sbSql.append("' and a.estatus <> 'A'");
				sbSql.append(sbFilter);
				sbSql.append(appendFilter);
				sbSql.append(" and (select fn_cja_saldo_fact(a.facturar_a,a.compania,a.codigo,a.grang_total) from dual) > 0");
				
				//if (applyOrderBy) sbSql.append(" /*union*/ order by a.fecha desc ");
				
			}//docType = F 
			else if (docType.equalsIgnoreCase("D"))
			{
				sbSql = new StringBuffer();
				sbSql.append("select a.fecha_ingreso as fecha_ord ,'");
				sbSql.append(tipoCliente);
				sbSql.append("' as ref_type, 'D' as doc_type, ''||a.secuencia as doc_no, a.compania, 'PAC' as ref_to, ''||a.pac_id as cliente, a.pac_id, a.secuencia as admision, null as cod_empresa, null as factura, null as remanente, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fecha, 0 as monto_total, 0 as monto_deuda, a.estado as estado_adm, a.categoria as categoria_adm, (select descripcion from tbl_adm_categoria_admision where codigo = a.categoria) as categoria_adm_desc, (select nombre_corto from tbl_adm_categoria_admision where codigo = a.categoria) as categoria_adm_corto, (select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id) as nombre, ' ' as ubicacion ");
				sbSql.append(" , '-' dgiDocto ");
				sbSql.append(",'-' sInicial from tbl_adm_admision a where a.compania = ");
				sbSql.append(compania);
				sbSql.append(" and a.pac_id = ");
				sbSql.append(refId);
				sbSql.append(" and a.estado not in ('I','N') and not exists (select admi_secuencia from tbl_fac_factura where pac_id = a.pac_id and admi_secuencia = a.secuencia and compania = a.compania and estatus <> 'A')");
				sbSql.append(sbFilter);
				sbSql.append(appendFilter);
				//if (applyOrderBy) sbSql.append(" /*union*/ order by a.fecha_ingreso desc ");
			}//docType = D
		}//tipoCliente = P
		else if (tipoCliente.equalsIgnoreCase("O"))
		{
			sbSql = new StringBuffer();
			if(referTo.equals("PLAN")){

				sbSql.append("select a.fecha as fecha_ord, a.facturar_a as ref_type, 'F' as doc_type, a.codigo as doc_no, a.compania, (select refer_to from tbl_fac_tipo_cliente where codigo = a.cliente_otros and compania = a.compania) as ref_to, a.nombre_cliente as cliente, null as pac_id, null as admision, null as cod_empresa, a.codigo as factura, null as remanente, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.grang_total as monto_total, (select fn_cja_saldo_fact(a.facturar_a,a.compania,a.codigo,a.grang_total) from dual) as monto_deuda, (select estado from tbl_adm_admision where pac_id = a.pac_id and secuencia = a.admi_secuencia) as estado_adm, (select categoria from tbl_adm_admision where pac_id = a.pac_id and secuencia = a.admi_secuencia) as categoria_adm, (select (select descripcion from tbl_adm_categoria_admision where codigo = z.categoria) from tbl_adm_admision z where z.pac_id = a.pac_id and z.secuencia = a.admi_secuencia) as categoria_adm_desc, null categoria_adm_corto, a.nombre_cliente as nombre, ' ' as ubicacion, '-' dgiDocto,nvl(a.comentario,'-') sInicial from tbl_fac_factura a where a.compania = ");
				sbSql.append(compania);
				sbSql.append(" and a.facturar_a = '");
				sbSql.append(tipoCliente);
				sbSql.append("' and a.estatus = 'P' and a.grang_total > 0 and a.cliente_otros = ");
				sbSql.append(refType);
				sbSql.append(" and cod_otro_cliente = '");
				sbSql.append(refId);
				sbSql.append("'");
			} else {
			sbSql.append(" select a.fecha as fecha_ord, a.facturar_a as ref_type, 'F' as doc_type, a.codigo as doc_no, a.compania, (select refer_to from tbl_fac_tipo_cliente where codigo = a.cliente_otros and compania = a.compania) as ref_to, a.cod_otro_cliente as cliente, null as pac_id, null as admision, null as cod_empresa, a.codigo as factura, null as remanente, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.grang_total as monto_total, (select fn_cja_saldo_fact(a.facturar_a,a.compania,a.codigo,a.grang_total) from dual) as monto_deuda, null as estado_adm, null as categoria_adm, ' ' as categoria_adm_desc, ' ' as categoria_adm_corto, a.nombre_cliente as nombre, ' ' as ubicacion, '-' dgiDocto,nvl(a.comentario,'-') sInicial from tbl_fac_factura a where a.compania = ");//, tbl_fac_trx b
			sbSql.append(compania);
			//sbSql.append(" and b.company_id = a.compania and a.codigo = b.other3"); /* and a.cod_otro_cliente = b.client_ref_id */
			sbSql.append(" and a.cod_otro_cliente = '");
			
			sbSql.append(refId);
			sbSql.append("' and a.cliente_otros = ");
			sbSql.append(refType);
			}
			sbSql.append(" and a.facturar_a = '");
			sbSql.append(tipoCliente);
			sbSql.append("' and a.estatus <> 'A'");
			sbSql.append(sbFilter);
			sbSql.append(appendFilter);
			sbSql.append(" and fn_cja_saldo_fact(a.facturar_a,a.compania,a.codigo,a.grang_total) > 0");
		}//tipoCliente = O
		if (!docType.equalsIgnoreCase("D"))
		{
			sbSql.append(" union all select a.fecha as fecha_ord, a.facturar_a as ref_type, 'F' as doc_type, a.codigo as doc_no, a.compania, (select refer_to from tbl_fac_tipo_cliente where codigo = a.cliente_otros and compania = a.compania) as ref_to, a.cod_otro_cliente as cliente, null as pac_id,  a.admi_secuencia as admision, null as cod_empresa, a.codigo as factura, null as remanente, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.grang_total as monto_total, (select fn_cja_saldo_fact(a.facturar_a,a.compania,a.codigo,a.grang_total) from dual) as monto_deuda, null as estado_adm, null as categoria_adm, ' ' as categoria_adm_desc, ' ' as categoria_adm_corto, nvl(a.nombre_cliente,(select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id)) as nombre, ' ' as ubicacion, '-' as dgiDocto,nvl(a.comentario,'-') sInicial from tbl_fac_factura a where a.compania = ");
			sbSql.append(compania);
			sbSql.append(" and exists (select null from tbl_adm_responsable r where r.estado = 'A' and r.ref_id = '");
			sbSql.append(refId);
			sbSql.append("' and ref_type = ");
			sbSql.append(refType);
			sbSql.append(" and r.pac_id = a.pac_id and r.admision = a.admi_secuencia and (r.ref_id <> r.pac_id or (r.ref_id = r.pac_id and a.cliente_otros <> r.ref_type)) )");
			sbSql.append(sbFilter);
			sbSql.append(appendFilter);
			sbSql.append(" and a.facturar_a = 'P' and a.estatus <> 'A' and (select fn_cja_saldo_fact(a.facturar_a,a.compania,a.codigo,a.grang_total) from dual) > 0 ");
			if(factXTipoClte.equals("N")){
			sbSql.append(" union all select a.fecha as fecha_ord, a.facturar_a as ref_type, 'F' as doc_type, a.codigo as doc_no, a.compania, (select refer_to from tbl_fac_tipo_cliente where codigo = a.cliente_otros and compania = a.compania) as ref_to, a.cod_otro_cliente as cliente, null as pac_id,  a.admi_secuencia as admision, null as cod_empresa, a.codigo as factura, null as remanente, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.grang_total as monto_total, (select fn_cja_saldo_fact(a.facturar_a,a.compania,a.codigo,a.grang_total) from dual) as monto_deuda, null as estado_adm, null as categoria_adm, ' ' as categoria_adm_desc, ' ' as categoria_adm_corto, nvl(a.nombre_cliente,(select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id)) as nombre, ' ' as ubicacion, '-' as dgiDocto,nvl(a.comentario,'-') sInicial from tbl_fac_factura a where a.compania = ");
			sbSql.append(compania);
			sbSql.append(" and exists ( select null from tbl_cxc_cliente_particular r where r.ref_id_resp = '");
			sbSql.append(refId);
			sbSql.append("' and ref_type_resp = ");
			sbSql.append(refType);
			sbSql.append(" and to_char(r.codigo) = a.cod_otro_cliente and (r.ref_id_resp <> r.codigo or (r.ref_id_resp = r.codigo and a.cliente_otros <> r.ref_type_resp)) )");
			sbSql.append(sbFilter);
			sbSql.append(appendFilter);
			sbSql.append(" and a.facturar_a = 'O' and a.estatus <> 'A' and (select fn_cja_saldo_fact(a.facturar_a,a.compania,a.codigo,a.grang_total) from dual) > 0 ");
			}
			
		}
		if(applyOrderBy && !docType.equalsIgnoreCase("D")){ sbSql.append(" order by 1 ");if(!order.trim().equals("")&&order.trim().equals("D"))sbSql.append(" desc ");else sbSql.append(" asc ");}
		//20110524 jacinto: sin "ORDER BY" ya que esto hace que demore la búsqueda. también cambió el query de paginación y se removió el query que hace el conteo de todos los registros filtrados
		if (sbSql.length() > 0 && request.getParameter("docNo") != null) al = SQLMgr.getDataList("select * from (select rownum as rn, tmp.* from ("+sbSql+") tmp where rownum <= "+nextVal+") where rn >= "+previousVal);
		rowCount = al.size();
	}//fp = recibos

	if (searchDisp==null) searchDisp="Listado";
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
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'FACTURAS - '+document.title;
function chkMsg(k){<% if (tipoCliente.equalsIgnoreCase("P") && docType.equalsIgnoreCase("F")) { %>if(eval('document.facturas.chkFact'+k).checked){var factura=eval('document.facturas.factura'+k).value;var ubicacion=eval('document.facturas.ubicacion'+k).value;var montoPlanilla=parseFloat(getDBData('<%=request.getContextPath()%>','nvl(sum(decode(tipo_transaccion,\'P\',monto,\'D\',-monto)),0)','tbl_pla_autoriza_desc_detpago','num_referencia = \''+factura+'\' and cod_compania = <%=session.getAttribute("_companyId")%> and procesado_caja = \'N\'',''));if(montoPlanilla==0){if(ubicacion=='PLANILLA'||ubicacion=='RECURSOS HUMANOS')alert('Sr. Usuario: La factura #'+factura+' está actualmente en descuento directo por planilla!!!');}else{alert('Sr. Usuario: La factura #'+factura+' tiene un monto de '+montoPlanilla+' descontado en planilla y que no ha sido reportado aún!!!');}}<% } %>}

$(function() {
	$("input[type='checkbox'][name*='chkFact']").click(function(e){
		$("#"+this.name+"Dummy").val(this.value)
	});
});
function dummySetter(name, value) {
	$("#"+name+"Dummy").val(value);
}
function doDistribute(){
	var wPagoTotal=window.opener.getPagoTotal();
	var wPagoTotalAplicado=parseFloat(window.opener.document.formDetalle.total.value);
	var wSaldoAplicar=parseFloat(wPagoTotal-wPagoTotalAplicado);
	var keySize=eval('document.facturas.keySize').value;
	//alert(wSaldoAplicar);
	var aplicadoTotal=0.00;
	var porcentajeAplicar=parseInt(eval('document.search01.porcentajeAplicar').value);
	if(porcentajeAplicar == null || porcentajeAplicar == '' || porcentajeAplicar==0) porcentajeAplicar=100;
	if(wSaldoAplicar > 0){
	for(i=0;i<keySize;i++){
	montoDeuda = parseFloat(eval('document.facturas.monto_deuda'+i).value);
	montoAplicar = montoDeuda * porcentajeAplicar / 100;
	//alert(aplicadoTotal+'----'+montoAplicar.toFixed(2));
	if(parseFloat(aplicadoTotal+parseFloat(montoAplicar.toFixed(2))) <= wSaldoAplicar){
	aplicadoTotal= parseFloat(aplicadoTotal + parseFloat(montoAplicar.toFixed(2)));
	eval('document.facturas.aplicar'+i).value = montoAplicar.toFixed(2);
	eval('document.facturas.chkFact'+i).checked=true;
	dummySetter('chkFact'+i, i); }else{
	eval('document.facturas.aplicar'+i).value = (wSaldoAplicar-aplicadoTotal).toFixed(2);
	eval('document.facturas.chkFact'+i).checked=true;
	dummySetter('chkFact'+i, i);
	break;
	    }
	}
	}//if saldo greater then 0 then
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE FACTURAS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="0">
<% fb = new FormBean("search01",request.getContextPath()+request.getServletPath()); %>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tipoCliente",tipoCliente)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("compania",compania)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("referTo",referTo)%>
<%=fb.hidden("refId",refId)%>
<%=fb.hidden("refType",refType)%>
<%=fb.hidden("flag",flag)%>

		<tr class="TextFilter">
			<td width="100%">
				Tipo Documento
				<%=fb.select("docType",docTypeOpt,docType,false,false,0,"Text10",null,"onChange=\"javascript:document.search01.submit();\"",null,"")%>
&nbsp;
				Documento #
				<%=fb.textBox("docNo","",false,false,false,10,40,"Text10",null,null)%>
				
				&nbsp;Fecha&nbsp;
					<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="2" />
						<jsp:param name="nameOfTBox1" value="fDate" />
						<jsp:param name="valueOfTBox1" value="<%=fDate%>" />
						<jsp:param name="nameOfTBox2" value="tDate" />
						<jsp:param name="valueOfTBox2" value="<%=tDate%>" />
						<jsp:param name="fieldClass" value="Text10" />
						<jsp:param name="buttonClass" value="Text10" />
						<jsp:param name="clearOption" value="true" />
					</jsp:include>
&nbsp;ORDEN<%=fb.select("order","D=DESCENDENTE,A=ASCENDENTE",order,false,false,0,"Text10",null,null,null,"")%>&nbsp;
				Doc. Fiscal #
				<%=fb.textBox("docFiscal","",false,false,false,10,40,"Text10",null,null)%>
	
				<%// if (tipoCliente.equalsIgnoreCase("O")) { %>
				&nbsp;Nombre
				<%=fb.textBox("aNombre","",false,false,false,30,"Text10",null,null)%>
				<%// } %>
				<%=fb.submit("go","Ir")%>
			</td>
		</tr>
		<% if (tipoCliente.equalsIgnoreCase("E")) { %><tr class="TextFilter">
			<td width="100%">
		% Aplicar
				<%=fb.textBox("porcentajeAplicar","100",false,false,false,10,40,"Text10",null,null)%>	&nbsp;<%=fb.button("aplicar","Aplicar",true,false,null,null,"onClick=\"javascript:doDistribute();\"","Distribute")%>
		</td>
		</tr><% } %>
<%=fb.formEnd()%>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%fb = new FormBean("facturas",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+nxtVal)%>
<%=fb.hidden("previousVal",""+preVal)%>
<%=fb.hidden("nextValP",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousValP",""+(preVal-recsPerPage))%>
<%=fb.hidden("nextValN",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousValN",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tipoCliente",tipoCliente)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("compania",compania)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("referTo",referTo)%>
<%=fb.hidden("refId",refId)%>
<%=fb.hidden("refType",refType)%>
<%=fb.hidden("docType",docType)%>
<%=fb.hidden("docNo",docNo)%>
<%=fb.hidden("docFiscal",docFiscal)%>
<%=fb.hidden("aNombre",aNombre)%>
<%=fb.hidden("flag",flag)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("order",order)%>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr class="TextPager">
			<td align="right">
				<%=fb.submit("save","Agregar",true,false)%>
				<%=fb.submit("saveContinue","Agregar y Continuar",true,false)%>
				<%=fb.button("cancel","Cerrar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%"><%=(preVal != 1)?fb.submit("previousT","<<-"):""%></td>
			<td width="40%"><%=rowCount%> Registro(s) Mostrado(s)</td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
			<td width="10%" align="right"><%=(recsPerPage == al.size()/*!(rowCount <= nxtVal)*/)?fb.submit("nextT","->>"):""%></td>
		</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
		<table align="center" width="100%" cellpadding="1" cellspacing="1" id="list">
		<tr class="TextHeader" align="center">
			<td width="8%">Tipo Doc.</td>
			<td width="8%">Doc. #</td>
			<td width="16%">Fiscal#</td>
			<td width="5%">Adm.</td>
			<td width="6%">Cat.</td>
			<td width="8%">Fecha</td>
			<td width="8%">Monto Total</td>
			<td width="8%">Monto Pend.</td>
			<td width="8%">Cliente</td>
			<% if (tipoCliente.equalsIgnoreCase("E")) { %>
			<td width="14%">Nombre Cliente</td>
			<td width="6%">Aplicar</td>
			<% } else { %>
			<td width="20%">Nombre Cliente</td>
			<% } %>
			<td width="5%">&nbsp;</td>
		</tr>
<% if (al.size() == 0) { %>
		<tr>
			<td colspan="<%=(tipoCliente.equalsIgnoreCase("E"))?12:11%>" class="TextRow01" align="center"><font color="#FF0000">
				<% if (request.getParameter("docNo") == null) { %>
				I N T R O D U Z C A &nbsp; P A R A M E T R O S &nbsp; P A R A &nbsp; B U S Q U E D A
				<% } else { %>
				N O &nbsp; H A Y &nbsp; R E G I S T R O S &nbsp; E N C O N T R A D O S
				<% } %>
			</font></td>
		</tr>
<% } %>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	String docTypeDisplay = "";
	if (cdo.getColValue("doc_type").equalsIgnoreCase("F")) docTypeDisplay = "FACTURA";
	else if (cdo.getColValue("doc_type").equalsIgnoreCase("D")) docTypeDisplay = "ADMISION";
	else if (cdo.getColValue("doc_type").equalsIgnoreCase("R")) docTypeDisplay = "REMANENTE";
%>
		<%=fb.hidden("doc_type"+i,cdo.getColValue("doc_type"))%>
		<%=fb.hidden("doc_no"+i,cdo.getColValue("doc_no"))%>
		<%=fb.hidden("docFiscal"+i,cdo.getColValue("dgiDocto"))%>
		<%=fb.hidden("admision"+i,cdo.getColValue("admision"))%>
		<%=fb.hidden("remanente"+i,cdo.getColValue("remanente"))%>
		<%=fb.hidden("factura"+i,cdo.getColValue("factura"))%>
		<%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
		<%=fb.hidden("monto_total"+i,cdo.getColValue("monto_total"))%>
		<%=fb.hidden("monto_deuda"+i,cdo.getColValue("monto_deuda"))%>
		<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
		<%=fb.hidden("estatus"+i,cdo.getColValue("estatus"))%>
		<%=fb.hidden("sw"+i,cdo.getColValue("sw"))%>
		<%=fb.hidden("tipo_transaccion"+i,cdo.getColValue("tipo_transaccion"))%>
		<%=fb.hidden("estado_adm"+i,cdo.getColValue("estado_adm"))%>
		<%=fb.hidden("categoria_adm"+i,cdo.getColValue("categoria_adm"))%>
		<%=fb.hidden("categoria_adm_desc"+i,cdo.getColValue("categoria_adm_desc"))%>
		<%=fb.hidden("ubicacion"+i,cdo.getColValue("ubicacion"))%>
		<%=fb.hidden("sInicial"+i,cdo.getColValue("sInicial"))%>
		<%=fb.hidden("chkFact"+i+"Dummy", "")%>
		
		<%
		String dummySetter = (vDoc.contains(cdo.getColValue("doc_type")+"-"+cdo.getColValue("doc_no")))?"":" onclick=\"dummySetter('chkFact"+i+"', "+i+")\"";
		%>
		
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" <%=dummySetter%>>
			<td align="center"><%=docTypeDisplay%></td>
			<td align="center"><%=cdo.getColValue("doc_no")%></td>
			<td align="center"><%=cdo.getColValue("dgiDocto")%></td>
			<td align="center"><%=(cdo.getColValue("doc_type").equalsIgnoreCase("F")||cdo.getColValue("doc_type").equalsIgnoreCase("D"))?cdo.getColValue("admision"):""%></td>
			<td align="center"><%=(cdo.getColValue("doc_type").equalsIgnoreCase("F")||cdo.getColValue("doc_type").equalsIgnoreCase("D"))?cdo.getColValue("categoria_adm_corto"):""%></td>
			<td align="center"><%=cdo.getColValue("fecha")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_total"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_deuda"))%></td>
			<td align="center"><%=cdo.getColValue("cliente")%></td>
			<td align="left"><%=cdo.getColValue("nombre")%></td>
			<% if (tipoCliente.equalsIgnoreCase("E")) { %><td align="left"><%=fb.decBox("aplicar"+i,cdo.getColValue("monto_deuda"),false,false,true,15,10.2,"Text10","","")%></td><% } %>
			<td align="center"><%=(vDoc.contains(cdo.getColValue("doc_type")+"-"+cdo.getColValue("doc_no")))?"Elegido":fb.checkbox("chkFact"+i,""+i,false,false,"","","onClick=\"javascript:chkMsg("+i+")\"")%>
			
			<%=fb.hidden("que_lo_que_es"+i, " ** "+i)%>
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
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
			<td width="40%"><%=rowCount%> Registro(s) Mostrado(s)</td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
			<td width="10%" align="right"><%=(recsPerPage == al.size()/*!(rowCount <= nxtVal)*/)?fb.submit("nextB","->>"):""%></td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr class="TextPager">
			<td align="right">
				<%=fb.submit("save","Agregar",true,false)%>
				<%=fb.submit("saveContinue","Agregar y Continuar",true,false)%>
				<%=fb.button("cancel","Cerrar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		</table>
	</td>
</tr>
<%=fb.formEnd()%>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
else
{
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	for (int i=0; i<keySize; i++)
	{
		DetallePago dp = new DetallePago();

		dp.setDocType(request.getParameter("doc_type"+i));
		dp.setDocNo(request.getParameter("doc_no"+i));
		dp.setAdmiSecuencia(request.getParameter("admision"+i));
		dp.setCodRem(request.getParameter("remanente"+i));
		dp.setFacCodigo(request.getParameter("factura"+i));
		dp.setFecha(request.getParameter("fecha"+i));
		dp.setMontoTotal(request.getParameter("monto_total"+i));
		dp.setMontoDeuda(request.getParameter("monto_deuda"+i));
		if(tipoCliente.equalsIgnoreCase("E")) dp.setMonto(request.getParameter("aplicar"+i));
		else dp.setMonto(request.getParameter("monto_deuda"+i));
		dp.setNombrePaciente(request.getParameter("nombre"+i));
		dp.setEstatus(request.getParameter("estatus"+i));
		dp.setSw(request.getParameter("sw"+i));
		dp.setPagoPor(request.getParameter("doc_type"+i));
		dp.setTipoTransaccion(request.getParameter("tipo_transaccion"+i));
		dp.setAdmEstado(request.getParameter("estado_adm"+i));
		dp.setAdmCat(request.getParameter("categoria_adm"+i));
		dp.setAdmCatDesc(request.getParameter("categoria_adm_desc"+i));
		dp.setAnulada("N");
		if(tipoCliente.equalsIgnoreCase("P")||tipoCliente.equalsIgnoreCase("E")){if(docType.equalsIgnoreCase("F")&&request.getParameter("sInicial"+i)!=null && !request.getParameter("sInicial"+i).trim().equals("S/I"))dp.setDistribuir("S");else dp.setDistribuir("N");}
		else dp.setDistribuir("N");

	System.out.println(":::::::::::::::::::::::::::::::::::::::: "+request.getParameter("que_lo_que_es"+i));

		key = request.getParameter("key"+i);
		if (request.getParameter("chkFact"+i+"Dummy") != null && !request.getParameter("chkFact"+i+"Dummy").equals(""))
		{
			lastLineNo++;
			if (lastLineNo < 10) key = "00" + lastLineNo;
			else if (lastLineNo < 100) key = "0" + lastLineNo;
			else key = "" + lastLineNo;

			try
			{
				iDoc.put(key,dp);
				vDoc.addElement(dp.getDocType()+"-"+dp.getDocNo());
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&fg="+fg+"&flag="+flag+"&mode="+mode+"&tipoCliente="+tipoCliente+"&codigo="+codigo+"&compania="+compania+"&anio="+anio+"&referTo="+referTo+"&refId="+refId+"&refType="+refType+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&lastLineNo="+lastLineNo+"&docType="+request.getParameter("docType")+"&docNo="+request.getParameter("docNo")+"&docFiscal="+request.getParameter("docFiscal")+"&aNombre="+request.getParameter("aNombre")+"&fDate="+request.getParameter("fDate")+"&tDate="+request.getParameter("tDate")+"&order="+request.getParameter("order"));
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&fg="+fg+"&flag="+flag+"&mode="+mode+"&tipoCliente="+tipoCliente+"&codigo="+codigo+"&compania="+compania+"&anio="+anio+"&referTo="+referTo+"&refId="+refId+"&refType="+refType+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&lastLineNo="+lastLineNo+"&docType="+request.getParameter("docType")+"&docNo="+request.getParameter("docNo")+"&docFiscal="+request.getParameter("docFiscal")+"&aNombre="+request.getParameter("aNombre")+"&fDate="+request.getParameter("fDate")+"&tDate="+request.getParameter("tDate")+"&order="+request.getParameter("order"));
		return;
	}
	else if (request.getParameter("saveContinue") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&fg="+fg+"&flag="+flag+"&mode="+mode+"&tipoCliente="+tipoCliente+"&codigo="+codigo+"&compania="+compania+"&anio="+anio+"&referTo="+referTo+"&refId="+refId+"&refType="+refType+"&nextVal="+request.getParameter("nextVal")+"&previousVal="+request.getParameter("previousVal")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&lastLineNo="+lastLineNo+"&docType="+request.getParameter("docType")+"&docNo="+request.getParameter("docNo")+"&docFiscal="+request.getParameter("docFiscal")+"&aNombre="+request.getParameter("aNombre")+"&fDate="+request.getParameter("fDate")+"&tDate="+request.getParameter("tDate")+"&order="+request.getParameter("order"));
		return;
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow(){<% if (fp.equalsIgnoreCase("recibos")) { %>window.opener.location='../caja/reg_recibo_det.jsp?fg=<%=fg%>&fp=<%=flag%>&mode=<%=mode%>&tipoCliente=<%=tipoCliente%>&codigo=<%=codigo%>&compania=<%=compania%>&anio=<%=anio%>&change=1&lastLineNo=<%=lastLineNo%>';<% } %>window.close();}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>
<%
}
%>
