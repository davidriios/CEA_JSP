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
CommonDataObject cdoD = new CommonDataObject();
String id = request.getParameter("id");
String sinDepositos = request.getParameter("sinDepositos");

StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (sinDepositos == null) sinDepositos = "";
String fpOtros = "Otros";
try {fpOtros = java.util.ResourceBundle.getBundle("issi").getString("fpOtros"); } catch(Exception e){ fpOtros = "Otros";}

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		sbSql.append("select a.codigo, a.monto_cierre, to_char(a.hora_inicio,'dd/mm/yyyy hh12:mi:ss am') as hora_inicio, a.monto_inicial, a.cja_cajera_cod_cajera as cod_cajera");
		sbSql.append(", nvl((select nombre from tbl_cja_cajera where cod_cajera = a.cja_cajera_cod_cajera and compania = a.compania),' ') as cajero_nombre");
		sbSql.append(", nvl((select nombre from tbl_cja_cajera where cod_cajera = a.cod_supervisor_abre and compania = a.compania),' ') as supervisor_abre_nombre");
		sbSql.append(", (select cod_caja from tbl_cja_turnos_x_cajas where compania = a.compania and cod_turno = a.codigo) as cod_caja");
		sbSql.append(", to_char(nvl((select sum(decode(aa.doc_type, 'NCR', -bb.monto, bb.monto)) as monto from tbl_fac_trx aa, tbl_fac_trx_forma_pagos bb where bb.compania = aa.company_id and bb.doc_id = aa.doc_id and aa.turno = a.codigo and aa.company_id = a.compania and aa.company_id = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(" and aa.tipo_factura = 'CR'),0),'999999990.99') as credito");
		sbSql.append(", to_char(nvl((select sum(nvl(total_discount,0) + nvl(total_discount_gravable,0)) from tbl_fac_trx t where t.turno = a.codigo and t.company_id = a.compania and t.company_id = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append("),0),'999999990.99') as descuento");
		sbSql.append(", nvl((select initcap(descripcion) from tbl_cja_forma_pago where codigo = 9),'Total Vales') as label_vale from tbl_cja_turnos a where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and a.codigo = ");
		sbSql.append(id);
		System.out.println("query cierr_caja = "+sbSql.toString());
		cdo = SQLMgr.getData(sbSql.toString());
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
function calc(obj, valor){
	if(obj.value != '' || !isNaN(obj.value)){
		eval('document.form0.total_'+obj.name).value = (obj.value * valor).toFixed(2);
	} else {
		alert('Introduzca valores numéricos');
		obj.value = '';
	}
	calcTotal();
}
function calcTotal(){
	var total = 0.00;
	if(document.form0.total_cien.value!='' && !isNaN(document.form0.total_cien.value)) 													total += parseFloat(document.form0.total_cien.value);
	if(document.form0.total_cincuenta.value!='' && !isNaN(document.form0.total_cincuenta.value)) 								total += parseFloat(document.form0.total_cincuenta.value);
	if(document.form0.total_veinte.value!='' && !isNaN(document.form0.total_veinte.value)) 											total += parseFloat(document.form0.total_veinte.value);
	if(document.form0.total_diez.value!='' && !isNaN(document.form0.total_diez.value)) 													total += parseFloat(document.form0.total_diez.value);
	if(document.form0.total_cinco.value!='' && !isNaN(document.form0.total_cinco.value)) 												total += parseFloat(document.form0.total_cinco.value);
	if(document.form0.total_uno.value!='' && !isNaN(document.form0.total_uno.value)) 														total += parseFloat(document.form0.total_uno.value);
	if(document.form0.total_cincuenta_cent.value!='' && !isNaN(document.form0.total_cincuenta_cent.value)) 			total += parseFloat(document.form0.total_cincuenta_cent.value);
	if(document.form0.total_veinticinco_cent.value!='' && !isNaN(document.form0.total_veinticinco_cent.value))	total += parseFloat(document.form0.total_veinticinco_cent.value);
	if(document.form0.total_diez_cent.value!='' && !isNaN(document.form0.total_diez_cent.value)) 								total += parseFloat(document.form0.total_diez_cent.value);
	if(document.form0.total_cinco_cent.value!='' && !isNaN(document.form0.total_cinco_cent.value)) 							total += parseFloat(document.form0.total_cinco_cent.value);
	if(document.form0.total_uno_cent.value!='' && !isNaN(document.form0.total_uno_cent.value)) 									total += parseFloat(document.form0.total_uno_cent.value);
	document.form0.efectivo.value = (total).toFixed(2);
	//if(document.form0.efectivo.value!='' && !isNaN(document.form0.efectivo.value)) 									total += parseFloat(document.form0.efectivo.value);
	if(document.form0.cheque.value!='' && !isNaN(document.form0.cheque.value))
	total += parseFloat(document.form0.cheque.value);
	if(document.form0.otros.value!='' && !isNaN(document.form0.otros.value))
	total += parseFloat(document.form0.otros.value);
	if(document.form0.trx_deposito.value!='' && !isNaN(document.form0.trx_deposito.value))
	total += parseFloat(document.form0.trx_deposito.value);
	if(document.form0.tarjeta_credito.value!='' && !isNaN(document.form0.tarjeta_credito.value)) 									total += parseFloat(document.form0.tarjeta_credito.value);
	if(document.form0.tarjeta_debito.value!='' && !isNaN(document.form0.tarjeta_debito.value)) 									total += parseFloat(document.form0.tarjeta_debito.value);
	if(document.form0.total_vales.value!='' && !isNaN(document.form0.total_vales.value)) 									total += parseFloat(document.form0.total_vales.value);
	document.form0.total_cajero.value = (total).toFixed(2);
}
function  doSubmit()
{form0BlockButtons(true);document.form0.submit();}
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
		<%=fb.hidden("sinDepositos",""+sinDepositos)%>
		<tr class="TextHeader02">
			<td colspan="4"><cellbytelabel>CIERRE DE CAJA</cellbytelabel></td>
		</tr>
		<tr class="TextRow01" >
			<td width="20%" align="right"><cellbytelabel>Turno</cellbytelabel></td>
			<td width="30%"><%=cdo.getColValue("codigo")%></td>
			<td width="20%" align="right"><cellbytelabel>Fecha Inicial</cellbytelabel></td>
			<td width="30%"><%=cdo.getColValue("hora_inicio")%></td>
		</tr>
		<tr class="TextRow02" >
			<td align="right"><cellbytelabel>Fecha Final</cellbytelabel></td>
			<td><%=CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am")%></td>
			<td align="right"><cellbytelabel>Cajero</cellbytelabel></td>
			<td><%=cdo.getColValue("cajero_nombre")%></td>
		</tr>
		<tr class="TextRow02" >
			<td align="right"><cellbytelabel>Supervisor</cellbytelabel></td>
			<td><%=cdo.getColValue("supervisor_abre_nombre")%></td>
			<td align="right"><cellbytelabel>Efectivo Inicial</cellbytelabel></td>
			<td><%=cdo.getColValue("monto_inicial")%></td>
		</tr>
		<tr class="TextHeader02">
			<td colspan="4" align="center"><cellbytelabel>DETALLES</cellbytelabel></td>
		</tr>
		<tr class="TextRow02">
			<td align="right">$ 100 X&nbsp;
			<%=fb.decBox("cien",cdoD.getColValue("cien"),false,false,false,14,12.2, "text10", "", "onChange=\"javascript:calc(this, 100);\"", "", false, "tabindex=\"1\"")%>&nbsp;=&nbsp;      </td>
			<td>
			<%=fb.decBox("total_cien",cdoD.getColValue("total_cien"),false,false,true,14,12.2, "text10", "", "")%>      </td>
			<td align="right"><cellbytelabel>Efectivo</cellbytelabel></td>
			<td>
			<%=fb.decBox("efectivo",cdoD.getColValue("efectivo"),false,false,true,14,12.2, "text10", "", "onChange=\"javascript:calcTotal();\"")%>      </td>
		</tr>
		<tr class="TextRow02">
			<td align="right">$ 50 X&nbsp;
			<%=fb.decBox("cincuenta",cdoD.getColValue("cincuenta"),false,false,false,14,12.2, "text10", "", "onChange=\"javascript:calc(this, 50);\"", "", false, "tabindex=\"2\"")%>&nbsp;=&nbsp;      </td>
			<td>
			<%=fb.decBox("total_cincuenta",cdoD.getColValue("total_cincuenta"),false,false,true,14,12.2, "text10", "", "")%>      </td>
			<td align="right"><cellbytelabel>Cheque</cellbytelabel></td>
			<td>
			<%=fb.decBox("cheque",cdoD.getColValue("cheque"),false,false,false,14,12.2, "text10", "", "onChange=\"javascript:calcTotal();\"", "", false, "tabindex=\"13\"")%>      </td>
		</tr>
		<tr class="TextRow02" >
			<td align="right">$ 20 X&nbsp;
			<%=fb.decBox("veinte",cdoD.getColValue("veinte"),false,false,false,14,12.2, "text10", "", "onChange=\"javascript:calc(this, 20);\"", "", false, "tabindex=\"3\"")%>&nbsp;=&nbsp;      </td>
			<td>
			<%=fb.decBox("total_veinte",cdoD.getColValue("total_veinte"),false,false,true,14,12.2, "text10", "", "")%>      </td>
			<td align="right"><cellbytelabel>Ach/Transferencia/Dep&oacute;sito</cellbytelabel></td>
			<td><%=fb.decBox("trx_deposito",cdoD.getColValue("trx_deposito"),false,false,false,14,12.2, "text10", "", "onChange=\"javascript:calcTotal();\"", "", false, "tabindex=\"14\"")%></td>
		</tr>
		<tr class="TextRow02" >
			<td align="right">$ 10 X&nbsp;
			<%=fb.decBox("diez",cdoD.getColValue("diez"),false,false,false,14,12.2, "text10", "", "onChange=\"javascript:calc(this, 10);\"", "", false, "tabindex=\"4\"")%>&nbsp;=&nbsp;      </td>
			<td>
			<%=fb.decBox("total_diez",cdoD.getColValue("total_diez"),false,false,true,14,12.2, "text10", "", "")%>      </td>
			<td align="right"><cellbytelabel>Tarjeta Cr&eacute;dito</cellbytelabel></td>
			<td><%=fb.decBox("tarjeta_credito",cdoD.getColValue("tarjeta_credito"),false,false,false,14,12.2, "text10", "", "onChange=\"javascript:calcTotal();\"", "", false, "tabindex=\"15\"")%></td>
		</tr>
		<tr class="TextRow02" >
			<td align="right">$ 5 X&nbsp;
			<%=fb.decBox("cinco",cdoD.getColValue("cinco"),false,false,false,14,12.2, "text10", "", "onChange=\"javascript:calc(this, 5);\"", "", false, "tabindex=\"5\"")%>&nbsp;=&nbsp;      </td>
			<td>
			<%=fb.decBox("total_cinco",cdoD.getColValue("total_cinco"),false,false,true,14,12.2, "text10", "", "")%>      </td>
			<td align="right"><cellbytelabel>Tarjeta D&eacute;bito</cellbytelabel></td>
			<td>
			<%=fb.decBox("tarjeta_debito",cdoD.getColValue("tarjeta_debito"),false,false,false,14,12.2, "text10", "", "onChange=\"javascript:calcTotal();\"", "", false, "tabindex=\"16\"")%>      </td>
		</tr>
		<tr class="TextRow02" >
			<td align="right">$ 1 X&nbsp;
			<%=fb.decBox("uno",cdoD.getColValue("uno"),false,false,false,14,12.2, "text10", "", "onChange=\"javascript:calc(this, 1);\"", "", false, "tabindex=\"6\"")%>&nbsp;=&nbsp;      </td>
			<td>
			<%=fb.decBox("total_uno",cdoD.getColValue("total_uno"),false,false,true,14,12.2, "text10", "", "")%>      </td>
			<td align="right"><cellbytelabel><%=fpOtros%></cellbytelabel></td>
			<td>
			<%=fb.decBox("otros",cdoD.getColValue("otros"),false,false,false,14,12.2, "text10", "", "onChange=\"javascript:calcTotal();\"", "", false, "tabindex=\"17\"")%>      </td>
		</tr>
		<tr class="TextRow02" >
			<td align="right">$ 0.50&nbsp;
			<%=fb.decBox("cincuenta_cent",cdoD.getColValue("cincuenta_cent"),false,false,false,14,12.2, "text10", "", "onChange=\"javascript:calc(this, 0.5);\"", "", false, "tabindex=\"7\"")%>&nbsp;=&nbsp;      </td>
			<td>
			<%=fb.decBox("total_cincuenta_cent",cdoD.getColValue("total_cincuenta_cent"),false,false,true,14,12.2, "text10", "", "")%>      </td>
			<td align="right"><%=cdo.getColValue("label_vale")%></td>
			<td><%=fb.decBox("total_vales",cdoD.getColValue("total_vales"),false,false,false,14,12.2, "text10", "", "onChange=\"javascript:calcTotal();\"", "", false, "tabindex=\"18\"")%>
			      </td>
		</tr>
		<tr class="TextRow02" >
			<td align="right">$ 0.25&nbsp;
			<%=fb.decBox("veinticinco_cent",cdoD.getColValue("veinticinco_cent"),false,false,false,14,12.2, "text10", "", "onChange=\"javascript:calc(this, 0.25);\"", "", false, "tabindex=\"8\"")%>&nbsp;=&nbsp;      </td>
			<td>
			<%=fb.decBox("total_veinticinco_cent",cdoD.getColValue("total_veinticinco_cent"),false,false,true,14,12.2, "text10", "", "")%>      </td>
			<td align="right" class="Text12Bold"><font class="RedTextBold"><cellbytelabel>Total del Cajero</cellbytelabel></font></td>
			<td><%=fb.decBox("total_cajero",cdoD.getColValue("total_cajero"),false,false,true,14,12.2, "text10", "", "", "", false, "tabindex=\"17\"")%></td>
		</tr>
		<tr class="TextRow02" >
			<td align="right">$ 0.10&nbsp;
			<%=fb.decBox("diez_cent",cdoD.getColValue("diez_cent"),false,false,false,14,12.2, "text10", "", "onChange=\"javascript:calc(this, 0.10);\"", "", false, "tabindex=\"9\"")%>&nbsp;=&nbsp;      </td>
			<td>
			<%=fb.decBox("total_diez_cent",cdoD.getColValue("total_diez_cent"),false,false,true,14,12.2, "text10", "", "")%>      </td>
			<td align="right" class="Text12Bold">Total Cr&eacute;dito</td>
			<td><%=fb.decBox("credito",cdo.getColValue("credito"),false,false,true,14,12.2, "text10", "", "")%></td>
		</tr>
		<tr class="TextRow02" >
			<td align="right">$ 0.05&nbsp;
			<%=fb.decBox("cinco_cent",cdoD.getColValue("cinco_cent"),false,false,false,14,12.2, "text10", "", "onChange=\"javascript:calc(this, 0.05);\"", "", false, "tabindex=\"10\"")%>&nbsp;=&nbsp;      </td>
			<td>
			<%=fb.decBox("total_cinco_cent",cdoD.getColValue("total_cinco_cent"),false,false,true,14,12.2, "text10", "", "")%>      </td>
			<td align="right">Total Descuento</td>
			<td><%=fb.decBox("descuento",cdo.getColValue("descuento"),false,false,true,14,12.2, "text10", "", "")%></td>
		</tr>
		<tr class="TextRow02" >
			<td align="right">$ 0.01&nbsp;
			<%=fb.decBox("uno_cent",cdoD.getColValue("uno_cent"),false,false,false,14,12.2, "text10", "", "onChange=\"javascript:calc(this, 0.01);\"", "", false, "tabindex=\"11\"")%>&nbsp;=&nbsp;      </td>
			<td>
			<%=fb.decBox("total_uno_cent",cdoD.getColValue("total_uno_cent"),false,false,true,14,12.2, "text10", "", "")%>      </td>
			<td align="right">&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
	 <tr class="TextRow02">
			<td colspan="4" align="right">
				<%=fb.button("save","Guardar",true,false,null,null, "onClick=\"javascript:showPopWin('../caja/iniciar_caja.jsp?fp=cerrar_caja&cod_caja="+cdo.getColValue("cod_caja")+"&compania_caja="+(String) session.getAttribute("_companyId")+"',winWidth*.55,_contentHeight*.35,null,null,'');\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>			</td>
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
<%
}//GET
else
{
	cdo = new CommonDataObject();
	cdo.addColValue("session_id",request.getParameter("cod_turno"));
	cdo.addColValue("cod_caja",request.getParameter("cod_caja"));
	cdo.addColValue("company_id",(String) session.getAttribute("_companyId"));
	cdo.addColValue("usuario",(String) session.getAttribute("_userName"));
	cdo.addColValue("cod_supervisor_cierra",request.getParameter("cod_supervisor_cierra"));
	if(request.getParameter("cien")!=null && !request.getParameter("cien").equals("")) cdo.addColValue("hundreds",request.getParameter("cien"));
	if(request.getParameter("total_cien")!=null && !request.getParameter("total_cien").equals("")) cdo.addColValue("tot_hundreds",request.getParameter("total_cien"));
	if(request.getParameter("cincuenta")!=null && !request.getParameter("cincuenta").equals("")) cdo.addColValue("fiftys",request.getParameter("cincuenta"));
	if(request.getParameter("total_cincuenta")!=null && !request.getParameter("total_cincuenta").equals("")) cdo.addColValue("tot_fiftys",request.getParameter("total_cincuenta"));
	if(request.getParameter("veinte")!=null && !request.getParameter("veinte").equals("")) cdo.addColValue("twentys",request.getParameter("veinte"));
	if(request.getParameter("total_veinte")!=null && !request.getParameter("total_veinte").equals("")) cdo.addColValue("tot_twentys",request.getParameter("total_veinte"));
	if(request.getParameter("diez")!=null && !request.getParameter("diez").equals("")) cdo.addColValue("tens",request.getParameter("diez"));
	if(request.getParameter("total_diez")!=null && !request.getParameter("total_diez").equals("")) cdo.addColValue("tot_tens",request.getParameter("total_diez"));
	if(request.getParameter("cinco")!=null && !request.getParameter("cinco").equals("")) cdo.addColValue("fives",request.getParameter("cinco"));
	if(request.getParameter("total_cinco")!=null && !request.getParameter("total_cinco").equals("")) cdo.addColValue("tot_fives",request.getParameter("total_cinco"));
	if(request.getParameter("uno")!=null && !request.getParameter("uno").equals("")) cdo.addColValue("ones",request.getParameter("uno"));
	if(request.getParameter("total_uno")!=null && !request.getParameter("total_uno").equals("")) cdo.addColValue("tot_ones",request.getParameter("total_uno"));
	if(request.getParameter("cincuenta_cent")!=null && !request.getParameter("cincuenta_cent").equals("")) cdo.addColValue("fifty_coins",request.getParameter("cincuenta_cent"));
	if(request.getParameter("total_cincuenta_cent")!=null && !request.getParameter("total_cincuenta_cent").equals("")) cdo.addColValue("tot_50coins",request.getParameter("total_cincuenta_cent"));
	if(request.getParameter("veinticinco_cent")!=null && !request.getParameter("veinticinco_cent").equals("")) cdo.addColValue("twentyfive_coins",request.getParameter("veinticinco_cent"));
	if(request.getParameter("total_veinticinco_cent")!=null && !request.getParameter("total_veinticinco_cent").equals("")) cdo.addColValue("tot_25coins",request.getParameter("total_veinticinco_cent"));
	if(request.getParameter("diez_cent")!=null && !request.getParameter("diez_cent").equals("")) cdo.addColValue("ten_coins",request.getParameter("diez_cent"));
	if(request.getParameter("total_diez_cent")!=null && !request.getParameter("total_diez_cent").equals("")) cdo.addColValue("tot_10coins",request.getParameter("total_diez_cent"));
	if(request.getParameter("cinco_cent")!=null && !request.getParameter("cinco_cent").equals("")) cdo.addColValue("five_coins",request.getParameter("cinco_cent"));
	if(request.getParameter("total_cinco_cent")!=null && !request.getParameter("total_cinco_cent").equals("")) cdo.addColValue("tot_5coins",request.getParameter("total_cinco_cent"));
	if(request.getParameter("uno_cent")!=null && !request.getParameter("uno_cent").equals("")) cdo.addColValue("one_coins",request.getParameter("uno_cent"));
	if(request.getParameter("total_uno_cent")!=null && !request.getParameter("total_uno_cent").equals("")) cdo.addColValue("tot_1coins",request.getParameter("total_uno_cent"));
	if(request.getParameter("efectivo")!=null && !request.getParameter("efectivo").equals("")) cdo.addColValue("total_cash",request.getParameter("efectivo"));
	if(request.getParameter("cheque")!=null && !request.getParameter("cheque").equals("")) cdo.addColValue("total_cheque",request.getParameter("cheque"));
	if(request.getParameter("trx_deposito")!=null && !request.getParameter("trx_deposito").equals("")) cdo.addColValue("total_accdeposit",request.getParameter("trx_deposito"));
	if(request.getParameter("tarjeta_credito")!=null && !request.getParameter("tarjeta_credito").equals("")) cdo.addColValue("total_creditcard",request.getParameter("tarjeta_credito"));
	if(request.getParameter("tarjeta_debito")!=null && !request.getParameter("tarjeta_debito").equals("")) cdo.addColValue("total_debitcard",request.getParameter("tarjeta_debito"));
	if(request.getParameter("total_cajero")!=null && !request.getParameter("total_cajero").equals("")) cdo.addColValue("final_total",request.getParameter("total_cajero"));
	if(request.getParameter("sinDepositos")!=null && !request.getParameter("sinDepositos").equals("")) cdo.addColValue("cierre_sindep",request.getParameter("sinDepositos"));
	if(request.getParameter("total_vales")!=null && !request.getParameter("total_vales").equals("")) cdo.addColValue("total_vales",request.getParameter("total_vales"));
	if(request.getParameter("otros")!=null && !request.getParameter("otros").equals("")) cdo.addColValue("otros",request.getParameter("otros"));
	//if(request.getParameter("comprobante")!=null && !request.getParameter("comprobante").equals("")) cdo.addColValue("comprobante",request.getParameter("comprobante"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	TrMgr.cerrarCaja(cdo);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<% if (TrMgr.getErrCode().equals("1")) { %>
	alert('<%=TrMgr.getErrMsg()%>');
<% if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/caja/caja_list.jsp")) { %>
	window.opener.location='<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/caja/caja_list.jsp")%>';
<% } else { %>
	window.opener.location='<%=request.getContextPath()%>/caja/mantenimientoturno_list.jsp?fp=cerrar';
<% } %>
	window.location='<%=request.getContextPath()%>/caja/ver_cierre_caja.jsp?id=<%=request.getParameter("cod_turno")%>';
<% } else throw new Exception(TrMgr.getErrMsg()); %>
}
function addMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>