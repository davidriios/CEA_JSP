<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.ResourceBundle" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%
/**
===============================================================================
===============================================================================
**/
SecMgr.setConnection(ConMgr);
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
String logoPath = ((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();
String fg = request.getParameter("fg");
String docId = request.getParameter("docId");
String tipoDocto = request.getParameter("tipoDocto");

int iconHeight = 70;
int iconWidth = 200;
if(fg==null)fg="FACT";
if(tipoDocto==null)tipoDocto="";

StringBuffer sbSql = new StringBuffer();
sbSql.append("select id, decode(tipo_docto,'ND','NDD','NC','NDC','FACT','FAC','FACP','FAC','NCP','NDC','NDP','NDD',tipo_docto) as tipo_docto, (case when tipo_docto in ('ND','NC','FACT') then 'FACTHOSP' else 'FACTPOS' end) as tipo_docto_orig, compania, anio, trim(to_char(nvl(monto,0),'999999999990.00')) as monto, nvl(impuesto,0) as impuesto, to_char(fecha,'dd/mm/yyyy') as fecha, usuario_creacion, fecha_creacion, (case when tipo_docto in ('NC','ND') then getDGICodigo(compania,cod_ref) else cod_ref end) as refFactura, tipo_docto_ref, nvl(impreso,'N') as impreso, identificacion, codigo_dgi, dv, campo3, campo7");
//sbSql.append(", trim(to_char((case when tipo_docto in ('FACP','NCP','NDP') then 0 else nvl(descuento,0) + (case when tipo_docto = 'FACT' or substr(codigo,1,2) = 'A-' then getMontoCopagoHon(compania,decode(substr(codigo,1,2),'A-',substr(codigo,3),codigo),'OT',null) else 0 end) end),'999999999990.00')) as totalDiscount");
sbSql.append(", trim(to_char(case when (case when tipo_docto in ('FACP','NCP','NDP') then 0 else (case when tipo_docto = 'FACT' then nvl(descuento,0) + getMontoCopagoHon(compania,decode(substr(codigo,1,2),'A-',substr(codigo,3),codigo),'OT',null) when substr(codigo,1,2) = 'A-' then (select sum(nvl(cantidad,1) * precio) from tbl_fac_dgi_docto_det where id = a.id) - (monto + nvl(descuento,0)) else 0 end) end) > (case when tipo_docto = 'FACT' or substr(codigo,1,2) = 'A-' then (select sum(z.monto + z.descuento + z.descuento2) from tbl_fac_detalle_factura z, tbl_cds_centro_servicio y where z.fac_codigo = a.codigo and z.imprimir_sino = 'S' and z.centro_servicio = y.codigo and y.tipo_cds <> 'T' and y.codigo != (case when nvl(get_sec_comp_param(-1,'SHOW_CDSH_DGI'),'Y') = 'Y' then -100 else 0 end)) else 0 end) then (case when tipo_docto = 'FACT' or substr(codigo,1,2) = 'A-' then (select sum(z.monto + z.descuento + z.descuento2) from tbl_fac_detalle_factura z, tbl_cds_centro_servicio y where z.fac_codigo = a.codigo and z.imprimir_sino = 'S' and z.centro_servicio = y.codigo and y.tipo_cds <> 'T' and y.codigo != (case when nvl(get_sec_comp_param(-1,'SHOW_CDSH_DGI'),'Y') = 'Y' then -100 else 0 end)) else 0 end) else (case when tipo_docto in ('FACP','NCP','NDP') then nvl(a.descuento,0) else (case when tipo_docto = 'FACT' then nvl(descuento,0) + getMontoCopagoHon(compania,decode(substr(codigo,1,2),'A-',substr(codigo,3),codigo),'OT',null) when substr(codigo,1,2) = 'A-' then (select sum(nvl(cantidad,1) * precio) from tbl_fac_dgi_docto_det where id = a.id) - (monto + nvl(descuento,0)) else 0 end) end) end,'999999999990.00')) as totalDiscount");
sbSql.append(", (case when tipo_docto in ('FACT') or substr(codigo,1,2) = 'A-' then getMontoCentroTercero(decode(substr(codigo,1,2),'A-',substr(codigo,3),codigo),compania) else ' ' end) as totalCentrosTerceros");
sbSql.append(", checkfactanulada(compania,codigo,tipo_docto) as anulada");
sbSql.append(", ruc_cedula as clientRUC, cliente as clientName, campo4 as clientAseg,  (select edad from vw_adm_paciente where pac_id=a.pac_id)  as clientAge, case when tipo_docto = 'FACT' or substr(codigo,1,2) = 'A-' then (select to_char(f_nac,'dd/mm/yyyy') from vw_adm_paciente where pac_id=a.pac_id) else campo6 end as clientDOB, campo1 as clientCategoria, campo2 as clientMedico");
sbSql.append(", codigo docRef, nvl(monto,0) - (nvl(descuento,0) + (case when tipo_docto = 'FACT' or substr(codigo,1,2) = 'A-' then getMontoCopago(compania,decode(substr(codigo,1,2),'A-',substr(codigo,3),codigo)) else 0 end)) as montoNeto, case when tipo_docto in ('ND','NDP') then 'NOTA DEBITO' when tipo_docto in ('NC','NCP') then 'NOTA CREDITO' else 'FACTURA' end as tipo_docto_desc");
sbSql.append(", trim(to_char((case when tipo_docto = 'FACT' or substr(codigo,1,2) = 'A-' then getMontoCopago(compania,decode(substr(codigo,1,2),'A-',substr(codigo,3),codigo)) else 0 end),'999999999990.00')) as totalCopago");
sbSql.append(", (case when tipo_docto in ('FACT') or substr(codigo,1,2) = 'A-' then trim(to_char(gettotalfactura(codigo,compania),'999,990.00')) else ' ' end) as subTotalplusCIII");
sbSql.append(", trim(to_char((select nvl(sum(nvl(descuento,0)),0) from tbl_fac_detalle_factura z where z.fac_codigo = a.cod_ref and z.compania = a.compania and exists (select null from tbl_cds_centro_servicio where codigo = z.centro_servicio and tipo_cds = 'T')),'999999999990.99')) as totalDescuento, to_char(fecha_impresion,'dd/mm/yyyy hh12:mi am') as fecha_impresion, decode(tipo_docto,'FACP',campo8,'NCP',campo8,' ') as observacion");
sbSql.append(" from tbl_fac_dgi_documents a where ");
if(fg.trim().equals("POS"))sbSql.append(" codigo = '");
else sbSql.append(" id = ");
sbSql.append(docId);
if(fg.trim().equals("POS")){sbSql.append("' and tipo_docto ='");sbSql.append(tipoDocto);sbSql.append("'");}
sbSql.append(" and compania = ");
sbSql.append((String) session.getAttribute("_companyId"));

CommonDataObject cdo = SQLMgr.getData(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select id, tipo_docto, compania, anio, codigo_trx, codigo, descripcion itemName, to_char(nvl(cantidad, 1), '999999999990.999') itemQty, to_char(precio, '999999999990.99') itemUnitPrice, to_char(nvl(precio,0)*nvl(cantidad,1), '999999999990.99') itemTotalPrice, nvl(impuesto, 0)impuesto, taxPerc, descuento, usuario_creacion from tbl_fac_dgi_docto_det dd where id = ");
sbSql.append(cdo.getColValue("id"));
if(cdo.getColValue("tipo_docto_orig").equals("FACTHOSP")){
	sbSql.append(" and exists (select null from tbl_cds_centro_servicio cds where cds.tipo_cds != 'T' and cds.codigo != 0 and (to_char(cds.codigo) = dd.codigo or dd.codigo is null))");
}
al = SQLMgr.getDataList(sbSql.toString());
sbSql = new StringBuffer();
sbSql.append("select  to_char(sum(precio*cantidad), '999999999990.99') itemTotalPrice, taxPerc from tbl_fac_dgi_docto_det where id = ");
sbSql.append(cdo.getColValue("id"));
sbSql.append(" group by taxPerc having taxPerc>0 order by taxPerc");
al2 = SQLMgr.getDataList(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select  sum(nvl(impuesto, 0))impuesto, taxPerc from tbl_fac_dgi_docto_det where id = ");
sbSql.append(cdo.getColValue("id"));
sbSql.append(" group by taxPerc having taxPerc>0 order by taxPerc ");
al3 = SQLMgr.getDataList(sbSql.toString());
ArrayList alFP = new ArrayList();
if(tipoDocto.equals("FACP")){
	sbSql = new StringBuffer();
	sbSql.append("select a.descripcion, sum(b.monto) monto from tbl_cja_forma_pago a, tbl_fac_trx_forma_pagos b where a.codigo = b.fp_codigo and b.compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and exists (select null from tbl_fac_trx t where t.other3 = '");
	sbSql.append(cdo.getColValue("docRef"));
	sbSql.append("' and t.doc_id = b.doc_id) group by a.descripcion");
	alFP = SQLMgr.getDataList(sbSql.toString());
}

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Ejecutar Proceso - '+document.title;
</script>
</head>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="" colspan="2">&nbsp;</td>
	</tr>
	<tr>
		<td class="TableBorder">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

            <table align="center" width="99%" cellpadding="0" cellspacing="1">
<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
				<tr>
          <td colspan="2">&nbsp;</td>
				</tr>
				<tr>
          <td width="50%" align="center" class="TableBorder">

					<img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" src="../images/company/<%=logoPath%>">
					<br>
					<b><%=cdo.getColValue("tipo_docto_desc")%>
					</td>
					<td width="50%" class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
						<tr class="">
							<td width="50%"><cellbytelabel>RUC/CIP</cellbytelabel>:<%=cdo.getColValue("clientRUC")%></td>
						</tr>
						<tr class="">
							<td><%=cdo.getColValue("clientName")%></td>
						</tr>
						<tr class="">
							<td><cellbytelabel>Aseguradora</cellbytelabel>:<%=cdo.getColValue("clientAseg")%></td>
						</tr>
						<tr class="">
							<td><cellbytelabel>Reference</cellbytelabel>:<%=cdo.getColValue("docRef")%></td>
						</tr>
						<tr class="">
							<td><cellbytelabel>Edad</cellbytelabel>:<%=cdo.getColValue("clientAge")%></td>
						</tr>
						<tr class="">
							<td><cellbytelabel>Fecha Nacimiento</cellbytelabel>:<%=cdo.getColValue("clientDOB")%></td>
						</tr>
						<tr class="">
							<td><cellbytelabel>Categor&iacute;a</cellbytelabel>:<%=cdo.getColValue("clientCategoria")%></td>
						</tr>
						<tr class="">
							<td><cellbytelabel>Medico</cellbytelabel>:<%=cdo.getColValue("clientMedico")%></td>
						</tr>
					</table></td>
				</tr>
				
				<tr class="">
					<td colspan="2" class="TableBorder"><%=cdo.getColValue("observacion")%></td>
				</tr>
				<tr class="">
					<td colspan="1" class="TableBorder"><%=cdo.getColValue("tipo_docto_desc")%>:<%=cdo.getColValue("codigo_dgi")%></td>
					<td colspan="1" class="TableBorder">Fecha:<%=cdo.getColValue("fecha_impresion")%></td>
				</tr>
				<tr>
          <td colspan="2" class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
							<tr class="">
                <td width="10%" align="center"><cellbytelabel>CANTIDAD</cellbytelabel></td>
                <td width="70%" align="center"><cellbytelabel>DESCRIPCION</cellbytelabel></td>
                <td width="10%" align="center"><cellbytelabel>PRECIO</cellbytelabel></td>
                <td width="10%" align="center"><cellbytelabel>SUBTOTAL</cellbytelabel></td>
              </tr>
<% if (al.size() == 0 && cdo.getColValue("tipo_docto_orig").equals("FACTHOSP")) { %>
              <tr class="">
                <td>&nbsp;</td>
                <td>CENTROS TERCEROS</td>
                <td align="right">0.00</td>
                <td align="right">0.00</td>
              </tr>
<% } %>
              <%
							Double subtotal = 0.00;

							for (int i=0; i<al.size(); i++)
							{
								CommonDataObject cd = (CommonDataObject) al.get(i);

								String color = "";
								if (i % 2 == 0) color = "";
							%>
              <tr class="">
                <td><%=cd.getColValue("itemQty")%></td>
                <td><%=cd.getColValue("itemName")%></td>
                <td align="right"><%=cd.getColValue("itemUnitPrice")%></td>
                <td align="right"><%=cd.getColValue("itemTotalPrice")%></td>
              </tr>
              <%
							subtotal+=Double.parseDouble(cd.getColValue("itemTotalPrice"));
							}
							if(subtotal!=0.00){
							%>
              <tr class="">
                <td colspan = "1">&nbsp;</td>
                <td><cellbytelabel>SUBTOTAL</cellbytelabel></td>
								<td>&nbsp;</td>
                <td align="right"><%=CmnMgr.getFormattedDecimal(subtotal)%></td>
              </tr>
							<%}
							if(!cdo.getColValue("totalDiscount").equals("0.00")){
							%>
              <tr class="">
                <td colspan = "1">&nbsp;</td>
                <td><cellbytelabel>DESC</cellbytelabel></td>
								<td>&nbsp;</td>
                <td align="right">-<%=CmnMgr.getFormattedDecimal(cdo.getColValue("totalDiscount"))%></td>
              </tr>
							<%}%>
            </table></td>
        </tr>
				<tr class="">
					<td width="50%" class="TableBorder">
						<table align="center" width="99%" cellpadding="0" cellspacing="1">
							<%if(al2.size()==0){%>
							  <tr>
								<td width="60%" align="left"><cellbytelabel>EXENTO</cellbytelabel></td>
								<td width="40%" align="right"><%=CmnMgr.getFormattedDecimal((subtotal - Double.parseDouble(cdo.getColValue("totalDiscount"))))%></td>
							  </tr>
							  <%}else{%>
							   <tr>
								<td width="60%" align="left" colspan="2">&nbsp;
								<table align="center" width="100%" cellpadding="0" cellspacing="1">
								<%
									for (int y=0; y<al2.size(); y++)
									{
										CommonDataObject cd = (CommonDataObject) al2.get(y);
		
										String color = "";
										if (y % 2 == 0) color = "";
										if(cd.getColValue("itemTotalPrice")!=null && !cd.getColValue("itemTotalPrice").trim().equals("")){
									%>
									  <tr class="">
										<td>SUB - TOTAL  A (<%=cd.getColValue("taxPerc")%> %)</td>
										<td align="right"><%=(cd.getColValue("itemTotalPrice")!=null&& !cd.getColValue("itemTotalPrice").trim().equals(""))?CmnMgr.getFormattedDecimal(cd.getColValue("itemTotalPrice")):""%></td>
									  </tr>
									<%}}%>
								</table>								
								</td>
								</tr> 
							  <%}%>
							  
							  <tr class="">
								<td width="60%" align="left"><cellbytelabel>SUBTOTAL DESCUENTOS</cellbytelabel></td>
								<td width="40%" align="right"><%=(cdo.getColValue("totalDiscount").equals("0.00")?"":"-"+CmnMgr.getFormattedDecimal(cdo.getColValue("totalDiscount")))%></td>
							  </tr>
            			</table>
					</td>
					<td width="50%" class="TableBorder">
						<table align="center" width="99%" cellpadding="0" cellspacing="1">
						  <tr>
							<td width="60%" align="left"><cellbytelabel>SUBTOTAL</cellbytelabel></td>
							<td width="40%" align="right"><%=CmnMgr.getFormattedDecimal((subtotal - Double.parseDouble(cdo.getColValue("totalDiscount"))))%></td>
						  </tr>
						  <%if(al3.size()!=0){%>
							   <tr>
								<td  align="left" colspan="2"> &nbsp;
								<table align="center" width="100%" cellpadding="0" cellspacing="1">
								<%
									for (int y=0; y<al3.size(); y++)
									{
										CommonDataObject cd = (CommonDataObject) al3.get(y);
		
										String color = "";
										if (y % 2 == 0) color = "";
										if(cd.getColValue("taxPerc")!=null && !cd.getColValue("taxPerc").trim().equals("")){
									%>
									  <tr class="">
										<td width="60%">ITBMS A (<%=cd.getColValue("taxPerc")%> %)</td>
										<td width="40%" align="right"><%=CmnMgr.getFormattedDecimal(cd.getColValue("impuesto"))%></td>
									  </tr>
									<%}}%>
								</table>								
								</td>
								</tr> 
							  <%}%>
						  <tr>
							<td width="60%" align="left"><b><cellbytelabel>TOTAL</cellbytelabel></td>
							<td width="40%" align="right"><%=CmnMgr.getFormattedDecimal((subtotal - Double.parseDouble(cdo.getColValue("totalDiscount"))+ Double.parseDouble(cdo.getColValue("impuesto"))))%></td>
						  </tr>
            </table></td>
        </tr>
				<tr class="">
					<td width="50%" class="TableBorder">
						<table align="center" width="99%" cellpadding="0" cellspacing="1">
							<tr>
								<td width="60%" align="left"><cellbytelabel>Centros Terceros</cellbytelabel>:</td>
								<td width="40%" align="right"><%=cdo.getColValue("totalCentrosTerceros")%></td>
							</tr>
							<% if (!cdo.getColValue("totalCopago").equals("0.00")) { %>
							<tr class="">
								<td width="60%" align="left"><cellbytelabel>Copago</cellbytelabel>:</td>
								<td width="40%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("totalCopago"))%></td>
							</tr>
							<% } %>
							<tr class="">
								<td width="60%" align="left"><cellbytelabel>Descuento</cellbytelabel>:</td>
								<td width="40%" align="right"><%=(cdo.getColValue("totalDescuento").equals("0.00")?"":CmnMgr.getFormattedDecimal(cdo.getColValue("totalDescuento")))%></td>
							</tr>
							<tr class="">
								<td width="60%" align="left"><cellbytelabel>TOTAL + TERCEROS</cellbytelabel>:</td>
								<td width="40%" align="right"><%=cdo.getColValue("subTotalplusCIII")%></td>
							</tr>
						</table>
					</td>
					<td width="50%" class="TableBorder">
						<table align="center" width="99%" cellpadding="0" cellspacing="1">
							<%
							if(tipoDocto.equals("FACP")){
							for(int i = 0;i<alFP.size();i++){
								CommonDataObject cdfp = (CommonDataObject) alFP.get(i);
							%>
							<tr>
								<td width="60%" align="left"><cellbytelabel><%=cdfp.getColValue("descripcion")%></cellbytelabel></td>
								<td width="40%" align="right"><%=CmnMgr.getFormattedDecimal(cdfp.getColValue("monto"))%><%//=CmnMgr.getFormattedDecimal((subtotal - Double.parseDouble(cdo.getColValue("totalDiscount"))+ Double.parseDouble(cdo.getColValue("impuesto"))))%></td>
							</tr>
							<%}} else {%>
							<tr>
								<td width="60%" align="left"><cellbytelabel>Efectivo</cellbytelabel></td>
								<td width="40%" align="right"><%=CmnMgr.getFormattedDecimal((subtotal - Double.parseDouble(cdo.getColValue("totalDiscount"))+ Double.parseDouble(cdo.getColValue("impuesto"))))%></td>
							</tr>
							<%}%>
						</table>
					</td>
				</tr>
				<tr class="" align="center">
					<td colspan = "2" align="right">
						<%=fb.button("cancel","Cerrar",false,false,"Text10",null,((fg.trim().equals("kardex"))?"onClick=\"javascript:window.close();\"":"onClick=\"javascript:parent.hidePopWin(false);\""))%>
					</td>
				</tr>
        <%=fb.formEnd(true)%>
            </table>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}
%>
