<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="TrMgr" scope="page" class="issi.caja.TurnosMgr"/>
<%
/**
================================================================================
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
TrMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoT = new CommonDataObject();
CommonDataObject cdoD = new CommonDataObject();
CommonDataObject cdoC = new CommonDataObject();
ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String id = request.getParameter("id");
String mode = request.getParameter("mode");
boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
String fpOtros = "Otros";
try {fpOtros = java.util.ResourceBundle.getBundle("issi").getString("fpOtros"); } catch(Exception e){ fpOtros = "Otros";}
int iconHeight = 20;
int iconWidth = 20;
boolean viewInfo = true;
if (!UserDet.getUserProfile().contains("0")) {

	sbSql = new StringBuffer();
	sbSql.append("select nvl(tipo,'C') as tipo from tbl_cja_cajera where usuario = '");
	sbSql.append(UserDet.getUserName());
	sbSql.append("' and compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	cdo = SQLMgr.getData(sbSql.toString());

	String showTo = "A";
	try { showTo = java.util.ResourceBundle.getBundle("issi").getString("system.shift"); } catch(Exception e) { System.out.println("* * * Parameter [system.shift] is not defined! * * *"); }
	if (cdo == null) throw new Exception("Solo para personal de caja!");
	else if (!showTo.equalsIgnoreCase("A") && !cdo.getColValue("tipo").equalsIgnoreCase(showTo)) viewInfo = false;

}

if (request.getMethod().equalsIgnoreCase("GET")) {

	String labelVale = "Total Vales";
	if (mode.equalsIgnoreCase("add")) {

		//cdo.addColValue("codigo",id);
		sbSql = new StringBuffer();
		sbSql.append("select a.codigo, a.monto_cierre, to_char(a.fecha,'dd/mm/yyyy')||' '||to_char(a.hora_inicio,'hh12:mi:ss am') as hora_inicio, a.monto_inicial, a.cja_cajera_cod_cajera as cod_cajera, b.nombre as cajero_nombre, nvl(c.nombre,' ') as supervisor_abre_nombre, d.cod_caja from tbl_cja_turnos a, tbl_cja_cajera b, tbl_cja_cajera c, tbl_cja_turnos_x_cajas d where a.cja_cajera_cod_cajera = b.cod_cajera and a.compania = b.compania and a.cod_supervisor_abre = c.cod_cajera(+) and a.compania = c.compania(+) and a.codigo = d.cod_turno and a.compania = d.compania and a.codigo = ");
		sbSql.append(id);
		sbSql.append(" and a.compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		cdo = SQLMgr.getData(sbSql.toString());

		sbSql = new StringBuffer();
		sbSql.append("select fn_cja_total_cajero(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",");
		sbSql.append(id);
		sbSql.append(",'S') as pago_total from dual");
		cdoT = SQLMgr.getData(sbSql.toString());

		sbSql = new StringBuffer();
		sbSql.append("select c.codigo, initcap(c.descripcion) as fp_label, to_char(nvl(b.monto,0),'999999990.99') as monto from tbl_cja_forma_pago c, (select a.fp_codigo, nvl(a.monto,0)-nvl(b.monto,0) monto from (select b.fp_codigo, sum(b.monto) as monto from tbl_cja_transaccion_pago a, tbl_cja_trans_forma_pagos b where b.compania = a.compania and b.tran_anio = a.anio and b.tran_codigo = a.codigo and a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and a.status = 'B' and a.turno = ");
		sbSql.append(id);
		sbSql.append(" and ((a.rec_status = 'A') or (a.rec_status = 'I' and a.turno = ");
		sbSql.append(id);
		sbSql.append(" and a.turno <> a.turno_anulacion)) and to_char(b.fp_codigo) != get_sec_comp_param(a.compania, 'FORMA_PAGO_CREDITO')");
		sbSql.append(" group by b.fp_codigo) a, (select f.company_id, fp.fp_codigo, sum (fp.monto) as monto from tbl_fac_trx f, tbl_fac_trx_forma_pagos fp where fp.compania = f.company_id and f.doc_id = fp.doc_id and f.doc_type = 'NCR' and f.company_id = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(" and f.turno = ");
		sbSql.append(id);
		sbSql.append(" group by f.company_id, fp.fp_codigo) b where a.fp_codigo = b.fp_codigo(+)) b where c.codigo = b.fp_codigo(+) union select -1, 'CREDITO' descripcion, to_char(nvl((select sum(decode(a.doc_type, 'NCR', -b.monto, b.monto)) as monto from tbl_fac_trx a, tbl_fac_trx_forma_pagos b where b.compania = a.company_id and b.doc_id = a.doc_id and a.turno = ");
		sbSql.append(id);
		sbSql.append(" and a.company_id = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(" and a.tipo_factura = 'CR'),0),'999999990.99') as monto from dual union select -2, 'Descuento' descripcion, to_char(nvl((select sum(nvl(total_discount, 0)+nvl(total_discount_gravable, 0)) from tbl_fac_trx where turno = ");
		sbSql.append(id);
		sbSql.append(" and company_id = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append("), 0),'999999990.99') monto from dual");
		sbSql.append(" union all select -3,  'Recibos Anulados', to_char(nvl(sum(nvl(pago_total,0)),0),'999999990.99') as monto from tbl_cja_transaccion_pago   where compania = ");
		sbSql.append((String) session.getAttribute("_companyId")); 
   		sbSql.append("and turno_anulacion = ");
		sbSql.append(id);
		sbSql.append("  and rec_status = 'I'  and turno <> turno_anulacion  and nvl(afectar_saldo,'x')='S' ");
		
		al = SQLMgr.getDataList(sbSql.toString());
		for (int i = 0; i < al.size(); i++) {
			CommonDataObject cdx = (CommonDataObject) al.get(i);
			cdoD.addColValue(cdx.getColValue("codigo"),cdx.getColValue("monto"));
			if (cdx.getColValue("codigo").equals("9")) labelVale = cdx.getColValue("fp_label");
		}

		sbSql = new StringBuffer();
		sbSql.append("select to_char(nvl(total_cash,0),'999,999,990.99') as efectivo, to_char(nvl(total_cheque,0),'999,999,990.99') as cheque, to_char(nvl(total_accdeposit,0),'999,999,990.99') as deposito, to_char(nvl(total_creditcard,0),'999,999,990.99') as tarjeta_credito, to_char(nvl(total_debitcard,0),'999,999,990.99') as tarjeta_debito, final_total, to_char(nvl(otros,0),'999,999,990.99') as otros, hundreds, tot_hundreds, fiftys,    tot_fiftys, twentys, tot_twentys, tens, tot_tens, fives, tot_fives, ones, tot_ones, fifty_coins, tot_50coins, twentyfive_coins, tot_25coins, ten_coins, tot_10coins, five_coins, tot_5coins, one_coins, tot_1coins, to_char(nvl(total_vales,0),'999,999,990.99') total_vales from tbl_cja_sesdetails where session_id = ");
		sbSql.append(id);
		sbSql.append(" and company_id = ");
		sbSql.append(session.getAttribute("_companyId"));
		cdoC = SQLMgr.getData(sbSql.toString());

	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
document.title="Cierre de Caja - "+document.title;
function printCierre(){abrir_ventana1('../caja/print_cierre_caja.jsp?id=<%=id%>');}
function doCierre(flag){
if(flag=='Z') showPopWin('../common/run_process.jsp?fp=cierre_caja&actType=3&docType=DGI'+'&docNo=X',winWidth*.75,winHeight*.65,null,null,'');
else if(flag=='X') showPopWin('../common/run_process.jsp?fp=cierre_caja&actType=4&docType=DGI'+'&docNo=X',winWidth*.75,winHeight*.65,null,null,'');
}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CAJA - CIERRE - CAJA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
		<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("cod_turno",cdo.getColValue("codigo"))%>
		<%=fb.hidden("cod_caja",cdo.getColValue("cod_caja"))%>
		<%=fb.hidden("cod_supervisor_cierra","")%>
		<tr class="">
			<td colspan="4" align="right">
			<authtype type='50'><a href="javascript:doCierre('Z')"><img height="<%=iconHeight+10%>" width="<%=iconWidth+10%>" class="ImageBorder" src="../images/printer_z.gif"> Corte Z</a></authtype>
			<authtype type='51'><a href="javascript:doCierre('X')"><img height="<%=iconHeight+10%>" width="<%=iconWidth+10%>" class="ImageBorder" src="../images/printer_x.gif">Corte X</a></authtype>
			</td>
		</tr>
		<tr class="TextHeader02">
			<td colspan="4"><cellbytelabel>CIERRE DE CAJA</cellbytelabel></td>
		</tr>
		<tr class="TextRow01">
			<td width="20%" align="right"><cellbytelabel>Turno</cellbytelabel></td>
			<td width="30%"><%=cdo.getColValue("codigo")%></td>
			<td width="20%" align="right"><cellbytelabel>Fecha Inicial</cellbytelabel></td>
			<td width="30%"><%=cdo.getColValue("hora_inicio")%></td>
		</tr>
		<tr class="TextRow02">
			<td align="right"><cellbytelabel>Fecha Final</cellbytelabel></td>
			<td><%=CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am")%></td>
			<td align="right"><cellbytelabel>Cajero</cellbytelabel></td>
			<td><%=cdo.getColValue("cajero_nombre")%></td>
		</tr>
		<tr class="TextRow02">
			<td align="right"><cellbytelabel>Supervisor</cellbytelabel></td>
			<td><%=cdo.getColValue("supervisor_abre_nombre")%></td>
			<td align="right"><cellbytelabel>Efectivo Inicial</cellbytelabel></td>
			<td><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_inicial"))%></td>
		</tr>
<%--
Formas de pago:
1 = Efectivo
2 = Cheques
3 = Tarjetas de Credito
4 = Transferencias
5 = ACH
7 = Credito
9 = Vales
--%>
<%
double total4 = 0.00, total5 = 0.00, totaltt = 0.00;
if (cdoD.getColValue("4") != null && !cdoD.getColValue("4").trim().equals("")) total4 = Double.parseDouble(cdoD.getColValue("4"));
if (cdoD.getColValue("5") != null && !cdoD.getColValue("5").trim().equals("")) total5 = Double.parseDouble(cdoD.getColValue("5"));
totaltt = (total4 + total5);

//double totalTT=0.00;
//totalTT=(Double.parseDouble(CmnMgr.getFormattedDecimal(cdoD.getColValue("4"))) + Double.parseDouble(CmnMgr.getFormattedDecimal(cdoD.getColValue("5")))) ;
//System.out.println("Geeetsh printing total de ACH############"+totalTT);
System.out.println("Geeetsh printing total de ACH############"+totaltt+"  transferiaa   "+cdoD.getColValue("4")+"    ach"+cdoD.getColValue("5"));
int nCol = 4;
if (viewInfo) nCol = 2;
%>
		<tr>
			<td colspan="<%=nCol%>" align="center" class="TableBorder">
				<table align="center" width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader02" align="center">
					<td colspan="2"><cellbytelabel>DETALLE DEL CAJERO</cellbytelabel></td>
				</tr>
				<tr class="TextRow02">
					<td align="right" width="50%"><cellbytelabel>Efectivo</cellbytelabel></td>
					<td width="50%"><%=fb.decBox("efectivo_c",cdoC.getColValue("efectivo"),false,false,true,14,12.2,"Text10","","")%></td>
				</tr>
				<tr class="TextRow02">
					<td align="right"><cellbytelabel>Cheque</cellbytelabel></td>
					<td><%=fb.decBox("cheque_c",cdoC.getColValue("cheque"),false,false,true,14,12.2,"Text10","","")%></td>
				</tr>
				<tr class="TextRow02">
					<td align="right"><cellbytelabel>Ach/Transferencia</cellbytelabel>/<cellbytelabel>Dep&oacute;sito</cellbytelabel></td>
					<td><%=fb.decBox("trx_deposito_c",cdoC.getColValue("deposito"),false,false,true,14,12.2,"Text10","","")%></td>
				</tr>
				<tr class="TextRow02">
					<td align="right"><cellbytelabel>Tarjeta Cr&eacute;dito</cellbytelabel></td>
					<td><%=fb.decBox("tarjeta_credito_c",cdoC.getColValue("tarjeta_credito"),false,false,true,14,12.2,"Text10","","")%></td>
				</tr>
				<tr class="TextRow02">
					<td align="right"><cellbytelabel>Tarjeta D&eacute;bito</cellbytelabel></td>
					<td><%=fb.decBox("tarjeta_debito_c",cdoC.getColValue("tarjeta_debito"),false,false,true,14,12.2,"Text10","","")%></td>
				</tr>
				<tr class="TextRow02">
					<td align="right"><cellbytelabel><%=fpOtros%></cellbytelabel></td>
					<td><%=fb.decBox("tarjeta_debito_c",cdoC.getColValue("otros"),false,false,true,14,12.2,"Text10","","")%></td>
				</tr>
				<tr class="TextRow02">
					<td align="right"><cellbytelabel><%=labelVale%></cellbytelabel></td>
					<td><%=fb.decBox("total_vales_c",cdoC.getColValue("total_vales"),false,false,true,14,12.2,"Text10","","")%></td>
				</tr>
				<tr class="TextRow02">
					<td align="right"><font class="RedTextBold"><cellbytelabel>Total del Cajero</cellbytelabel></font></td>
					<td><%=fb.decBox("total_cajero_c",CmnMgr.getFormattedDecimal(cdoC.getColValue("final_total")),false,false,true,14,12.2,"Text10","","")%></td>
				</tr>
				<tr class="TextRow02">
					<td align="right"><font class="Text12Bold"><cellbytelabel>Total Cr&eacute;dito</cellbytelabel></font></td>
					<td><%=fb.decBox("total_cajero_c",CmnMgr.getFormattedDecimal(cdoD.getColValue("-1")),false,false,true,14,12.2,"Text10","","")%></td>
				</tr>
				<tr class="TextRow02">
					<td align="right"><font class="Text12Bold"><cellbytelabel>Total Descuento</cellbytelabel></font></td>
					<td><%=fb.decBox("total_cajero_c",CmnMgr.getFormattedDecimal(cdoD.getColValue("-2")),false,false,true,14,12.2,"Text10","","")%></td>
				</tr>
				</table>
			</td>
			<% if (viewInfo) { %>
			<td colspan="<%=nCol%>" align="center" class="TableBorder" valign="top">
				<table align="center" width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader02" align="center">
					<td colspan="2"><cellbytelabel>DETALLE EN SISTEMA</cellbytelabel></td>
				</tr>
				<tr class="TextRow02">
					<td align="right" width="50%"><cellbytelabel>Efectivo</cellbytelabel></td>
					<td width="50%"><%=fb.decBox("efectivo",cdoD.getColValue("1"),false,false,true,14,12.2,"Text10","","")%></td>
				</tr>
				<tr class="TextRow02">
					<td align="right"><cellbytelabel>Cheque</cellbytelabel></td>
					<td><%=fb.decBox("cheque",cdoD.getColValue("2"),false,false,true,14,12.2,"Text10","","")%></td>
				</tr>
				<tr class="TextRow02">
					<td align="right"><cellbytelabel>Ach/Transferencia</cellbytelabel>/<cellbytelabel>Dep&oacute;sito</cellbytelabel></td>
					<td><%=fb.decBox("trx_deposito",""+CmnMgr.getFormattedDecimal(totaltt),false,false,true,14,12.2,"Text10","","")%></td>
				</tr>
				<tr class="TextRow02">
					<td align="right"><cellbytelabel>Tarjeta Cr&eacute;dito</cellbytelabel></td>
					<td><%=fb.decBox("tarjeta_credito",cdoD.getColValue("3"),false,false,true,14,12.2,"Text10","","")%></td>
				</tr>
				<tr class="TextRow02">
					<td align="right"><cellbytelabel>Tarjeta D&eacute;bito</cellbytelabel></td>
					<td><%=fb.decBox("tarjeta_debito",cdoD.getColValue("6"),false,false,true,14,12.2,"Text10","","")%></td>
				</tr>
				<tr class="TextRow02">
					<td align="right"><cellbytelabel>Reemplazo</cellbytelabel></td>
					<td><%=fb.decBox("reemplazo",cdoD.getColValue("0"),false,false,true,14,12.2,"Text10","","")%></td>
				</tr>
				<tr class="TextRow02">
					<td align="right"><cellbytelabel><%=labelVale%></cellbytelabel></td>
					<td><%=fb.decBox("vale",cdoD.getColValue("9"),false,false,true,14,12.2,"Text10","","")%></td>
				</tr>
				<tr class="TextRow02">
					<td align="right"><cellbytelabel>Recibos Anulados</cellbytelabel></td>
					<td><%=fb.decBox("anulaciones",cdoD.getColValue("-3"),false,false,true,14,12.2,"Text10","","")%></td>
				</tr>
				<tr class="TextRow02">
					<td align="right"><font class="RedTextBold"><cellbytelabel>Total del Cajero</cellbytelabel></font></td>
					<td><%=fb.decBox("total_cajero",CmnMgr.getFormattedDecimal(cdoT.getColValue("pago_total")),false,false,true,14,12.2,"Text10","","")%></td>
				</tr>	
				<tr class="TextRow02">
					<td align="right">&nbsp;</td>
					<td>&nbsp;</td>
				</tr>
				</table>
			</td>
			<% } %>
		</tr>
<%
if (viewInfo) {
	double tot_cajero = 0.00;
	double tot_sys = 0.00;

	if (cdoC.getColValue("final_total") != null && !cdoC.getColValue("final_total").trim().equals("")) tot_cajero = Double.parseDouble(cdoC.getColValue("final_total"));
	if (cdoT.getColValue("pago_total") != null && !cdoT.getColValue("pago_total").trim().equals("")) tot_sys = Double.parseDouble(cdoT.getColValue("pago_total"));
%>
		<% if (tot_cajero != tot_sys) { %>
		<tr class="TextHeader02">
			<td align="center" colspan="4"><font class="<%=(tot_cajero<tot_sys)?"RedTextBold":""%>"><%=(tot_cajero<tot_sys)?"FALTANTE:":"SOBRANTE:"%>&nbsp;<%=CmnMgr.getFormattedDecimal(tot_cajero-tot_sys)%></font></td>
		</tr>
		<% } %>
<% } %>
		<tr>
			<td colspan="4" class="TableBorder">
				<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextHeader02" align="center">
					<td colspan="13">. : DETALLES DEL EFECTIVO : .</td>
				</tr>
				<tr class="TextRow02">
					<td width="10%">&nbsp;</td>
					<td align="right" width="10%">100 X</td>
					<td align="right" width="10%"><%=cdoC.getColValue("hundreds")%> =</td>
					<td align="right" width="10%"><%=CmnMgr.getFormattedDecimal(cdoC.getColValue("tot_hundreds"))%></td>
					<td width="20%">&nbsp;</td>
					<td align="right" width="10%">0.50 X</td>
					<td align="right" width="10%"><%=cdoC.getColValue("fifty_coins")%> =</td>
					<td align="right" width="10%"><%=CmnMgr.getFormattedDecimal(cdoC.getColValue("tot_50coins"))%></td>
					<td width="10%">&nbsp;</td>
				</tr>
				<tr class="TextRow02">
					<td>&nbsp;</td>
					<td align="right">50 X</td>
					<td align="right"><%=cdoC.getColValue("fiftys")%> =</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdoC.getColValue("tot_fiftys"))%></td>
					<td>&nbsp;</td>
					<td align="right">0.25 X</td>
					<td align="right"><%=cdoC.getColValue("twentyfive_coins")%> =</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdoC.getColValue("tot_25coins"))%></td>
					<td>&nbsp;</td>
				</tr>
				<tr class="TextRow02">
					<td>&nbsp;</td>
					<td align="right">20 X</td>
					<td align="right"><%=cdoC.getColValue("twentys")%> =</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdoC.getColValue("tot_twentys"))%></td>
					<td>&nbsp;</td>
					<td align="right">0.10 X</td>
					<td align="right"><%=cdoC.getColValue("ten_coins")%> =</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdoC.getColValue("tot_10coins"))%></td>
					<td>&nbsp;</td>
				</tr>
				<tr class="TextRow02">
					<td>&nbsp;</td>
					<td align="right">10 X</td>
					<td align="right"><%=cdoC.getColValue("tens")%> =</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdoC.getColValue("tot_tens"))%></td>
					<td>&nbsp;</td>
					<td align="right">0.05 X</td>
					<td align="right"><%=cdoC.getColValue("five_coins")%> =</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdoC.getColValue("tot_5coins"))%></td>
					<td>&nbsp;</td>
				</tr>
				<tr class="TextRow02">
					<td>&nbsp;</td>
					<td align="right">5 X</td>
					<td align="right"><%=cdoC.getColValue("fives")%> =</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdoC.getColValue("tot_fives"))%></td>
					<td>&nbsp;</td>
					<td align="right">0.01 X</td>
					<td align="right"><%=cdoC.getColValue("one_coins")%> =</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdoC.getColValue("tot_1coins"))%></td>
					<td>&nbsp;</td>
				</tr>
				<tr class="TextRow02">
					<td>&nbsp;</td>
					<td align="right">1 X</td>
					<td align="right"><%=cdoC.getColValue("ones")%> =</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdoC.getColValue("tot_ones"))%></td>
					<td>&nbsp;</td>
					<td align="right">&nbsp;</td>
					<td align="right">&nbsp;</td>
					<td align="right">&nbsp;</td>
					<td>&nbsp;</td>
				</tr>
				</table>
			</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				<%=fb.button("imprimir","Imprimir",true,false,null,null,"onClick=\"javascript:printCierre()\"")%>
				<%=fb.button("cancel","Cerrar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<% } %>