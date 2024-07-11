<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
=========================================================================
=========================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String type = request.getParameter("type");
String id = request.getParameter("id");
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");
String filtro_fecha_fact = request.getParameter("filtro_fecha_fact");
if (filtro_fecha_fact == null) filtro_fecha_fact = "";
String agrupado = request.getParameter("agrupado");
if (agrupado == null) agrupado = "";

if (type == null) type = "";
if (id == null) id = "";
if (fDate == null) fDate = "";
if (tDate == null) tDate = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	double debito = 0.00;
	double credito = 0.00;
	double saldo = 0.00,saldo_inicial=0.00;

	if (!fDate.trim().equals("") && !tDate.trim().equals(""))
	{
		sbFilter.append(" and trunc(a.doc_date) between to_date('");
		sbFilter.append(fDate);
		sbFilter.append("','dd/mm/yyyy') and to_date('");
		sbFilter.append(tDate);
		sbFilter.append("','dd/mm/yyyy')");
	}
	if (filtro_fecha_fact.trim().equals("Y")) {
		sbFilter.append(" and trunc(a.fecha_factura) <= to_date('");
		sbFilter.append(tDate);
		sbFilter.append("', 'dd/mm/yyyy')");
	}
	if (!fDate.trim().equals(""))
	{
		sbSql = new StringBuffer();

		//sbSql.append("select nvl(saldo_inicial,0) saldo_inicial  from  (");

		sbSql.append("select nvl(sum(a.debito - a.credito),0) as saldo_inicial from vw_cxc_mov_new a where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and ((a.refer_type = ");
		sbSql.append(type);


		sbSql.append(" and a.refer_id = '");
		sbSql.append(id);
		sbSql.append("')/* or exists ( select null from tbl_adm_responsable r where r.estado ='A' and r.ref_id='");
		sbSql.append(id);
		sbSql.append("' and ref_type=");
		sbSql.append(type);
        sbSql.append(" and r.pac_id=a.pac_id and r.admision=a.admision and a.fact_a='P' )*/ ) and trunc(a.doc_date) < to_date('");
		sbSql.append(fDate);
		sbSql.append("','dd/mm/yyyy')  ");
		if (filtro_fecha_fact.trim().equals("Y")) {
			sbSql.append(" and trunc(a.fecha_factura) < to_date('");
			sbSql.append(fDate);
			sbSql.append("', 'dd/mm/yyyy')");
		}
		//sbSql.append(")");

		cdo = SQLMgr.getData(sbSql.toString());
		saldo = Double.parseDouble(cdo.getColValue("saldo_inicial"));
		saldo_inicial = saldo;
	}

	sbSql = new StringBuffer();
	sbSql.append("select a.doc_type, decode(a.doc_type,'FAC','FACTURA','ADJ','NOTA AJUSTE','REC','RECIBO','NCP', 'NOTA CREDITO (POS)','AUX','COMP. AUX.',a.doc_type) as doc_type_desc, a.compania, a.ref_type, a.ref_code, to_char(a.doc_date,'dd/mm/yyyy') as doc_date, a.doc_id, a.doc_no");
	
	if (agrupado.trim().equals("S"))sbSql.append(", sum(nvl(a.total,0))total,sum(nvl(a.debito,0))debito, sum(nvl(a.credito,0))  credito,'N' fecha_factura_mayor");
	else sbSql.append(", nvl(a.total,0)total, nvl(a.debito,0)debito, nvl(a.credito,0)  credito,fecha_factura_mayor");
	
	
	sbSql.append(" ,a.anio from vw_cxc_mov_new a where a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and ((a.refer_type = ");
	sbSql.append(type);
	sbSql.append(" and a.refer_id = '");
	sbSql.append(id);
	sbSql.append("' ) /* or exists ( select null from tbl_adm_responsable r where r.estado ='A' and r.ref_id='");
	sbSql.append(id);
	sbSql.append("' and refer_type=");
	sbSql.append(type);
	sbSql.append(" and r.pac_id=a.pac_id and r.admision=a.admision and a.fact_a='P' ) */) ");
	sbSql.append(sbFilter);
	if (agrupado.trim().equals("S"))
	{
			sbSql.append(" group by a.doc_date,a.doc_type, decode(a.doc_type,'FAC','FACTURA','ADJ','NOTA AJUSTE','REC','RECIBO','NCP', 'NOTA CREDITO (POS)','AUX','COMP. AUX.',a.doc_type), a.compania, a.ref_type, a.ref_code, to_char(a.doc_date,'dd/mm/yyyy'), a.doc_id, a.doc_no,a.anio ");
	}
	
	sbSql.append(" order by a.doc_date,a.doc_type,a.doc_no");
	al = SQLMgr.getDataList(sbSql.toString());
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function doAction(){newHeight();}
function view(docType,docId,anio,refType){var compania=<%=session.getAttribute("_companyId")%>;if(docType=='FACT'&&refType!='O')abrir_ventana1('../facturacion/print_factura.jsp?factura='+docId+'&compania='+compania);else if(docType=='ADJ')abrir_ventana1('../facturacion/notas_ajuste_cargo_dev.jsp?mode=view&codigo='+docId+'&compania='+compania);
else if(docType=='REC'){var doc=docId.split('-');abrir_ventana1('../caja/consulta_recibos.jsp?mode=view&codigo='+doc[1]+'&compania='+compania+'&anio='+doc[0]);
}else if(docType=='NCP'){parent.showPopWin('../facturacion/ver_impresion_dgi.jsp?fg=POS&mode=view&docId='+docId+'&tipoDocto='+docType,winWidth*.75,winHeight*.90,null,null,'');}
else if(docType=='FACT'&&refType=='O'){parent.showPopWin('../facturacion/ver_impresion_dgi.jsp?fg=POS&mode=view&docId='+docId+'&tipoDocto=FACP',winWidth*.75,winHeight*.90,null,null,'');}
else if(docType=='ADJ2')abrir_ventana1('../facturacion/notas_ajustes_config.jsp?mode=view&codigo='+docId+'&compania='+compania);
else if(docType=='AUX')abrir_ventana('../contabilidad/reg_auxiliar_det.jsp?mode=view&fg=CSCXC&idTrx='+docId+'&anio='+anio);

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table width="100%" align="center" cellpadding="1" cellspacing="1">
<tr class="TextHeader02">
	<td align="center" width="10%"><cellbytelabel>Tipo Doc</cellbytelabel>.</td>
	<td align="center" width="10%"><cellbytelabel>Fecha</cellbytelabel></td>
	<td align="center" width="14%"><cellbytelabel>No. Doc</cellbytelabel>.</td>
	<td align="center" width="30%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
	<td align="center" width="12%"><cellbytelabel>D&eacute;bito</cellbytelabel></td>
	<td align="center" width="12%"><cellbytelabel>Cr&eacute;dito</cellbytelabel></td>
	<td align="center" width="12%"><cellbytelabel>Saldo</cellbytelabel></td>
</tr>
<tr class="TextHeader01" align="center">
	<td align="right" colspan="4"><cellbytelabel>Saldo Inicial</cellbytelabel></td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("saldo_inicial"))%></td>
</tr>
<%

debito = saldo_inicial;
for (int i=0; i<al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i);

	String color = "";
	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
	if(cdo.getColValue("fecha_factura_mayor").equals("S")) color = "";
	debito += Double.parseDouble(cdo.getColValue("debito"));
	credito += Double.parseDouble(cdo.getColValue("credito"));
	saldo = debito - credito;

%>
<tr class="<%=color%>" align="center" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
	<td><a href="javascript:view('<%=cdo.getColValue("doc_type")%>','<%=cdo.getColValue("doc_id")%>','<%=cdo.getColValue("anio")%>','<%=cdo.getColValue("ref_type")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=cdo.getColValue("doc_type")%></a></td>
	<td><%=cdo.getColValue("doc_date")%></td>
	<td><%=cdo.getColValue("doc_no")%></td>
	<td align="left"><%=cdo.getColValue("doc_type_desc")%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("debito"))%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("credito"))%></td>
	<td align="right">
	<%if(saldo<0){%><label  class="<%=color%>" style="cursor:pointer"><label class="RedTextBold">&nbsp;&nbsp;<%}%>
		<%=CmnMgr.getFormattedDecimal(saldo)%>
	<%if(saldo<0){%></label></label><%}%>
	</td>
</tr>
<%
}
%>
<tr class="TextHeader02" align="center">
	<td align="right" colspan="4"><cellbytelabel>Total</cellbytelabel></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(debito)%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(credito)%></td>
	<td align="right"><font class="<%=(saldo < 0?"RedTextBold":"")%>"><%=CmnMgr.getFormattedDecimal(saldo)%></font></td>
</tr>
</table>
</body>
</html>
<%
}%>