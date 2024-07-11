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

String docId = request.getParameter("docId");
int iconHeight = 70;
int iconWidth = 200;

StringBuffer sbSql = new StringBuffer();

sbSql.append("select ruc, dv, client_ref_id, cod_caja, turno, centro_servicio, tipo_factura, cod_cajero, doc_id, doc_no, to_char(doc_date, 'dd/mm/yyyy') doc_date, doc_type, reference_id, reference_no, to_char(expiration, 'dd/mm/yyyy') expiration, delivery_address, client_id, client_name, company_id, status, observations, gross_amount, gross_amount_gravable, total_discount, total_discount_gravable, sub_total, sub_total_gravable, pay_tax, tax_percent, tax_amount, total_charges, net_amount, created_by, to_char(sys_date, 'dd/mm/yyyy') sys_date, modified_by, to_char(modified_date, 'dd/mm/yyyy') modified_date, printed, printed_no, printed_by, to_char(printed_date, 'dd/mm/yyyy') printed_date, other1, other2, other3, other4, other5, client_type, decode(doc_type, 'FAC', 'FACTURA', 'NDC', 'NOTA DE CREDITO', 'NDD', 'NOTA DE DEBITO') tipo_docto_desc from tbl_fac_trx where doc_id = ");



sbSql.append(docId);
CommonDataObject cdo = SQLMgr.getData(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select doc_id, line_no, codigo, descripcion itemName, to_char(nvl(cantidad, 1), '999999999990.999') itemQty, to_char(precio, '999999999990.99') itemUnitPrice, nvl(gravable_perc, 0) taxPerc, 0 descuento from tbl_fac_trxitems where doc_id = ");
sbSql.append(docId);
sbSql.append(" and tipo_descuento is null order by line_no");
al = SQLMgr.getDataList(sbSql.toString());
		
if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Ver Documento DGI - '+document.title;
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
							<td width="50%">RUC/CIP:<%=cdo.getColValue("ruc")%></td>				
						</tr>							
						<tr class="">
							<td><%=cdo.getColValue("client_name")%></td>				
						</tr>							
						<tr class="">
							<td></td>				
						</tr>							
						<tr class="">
							<td>Reference:<%=cdo.getColValue("reference_no")%></td>				
						</tr>							
						<tr class="">
							<td>&nbsp;</td>				
						</tr>							
						<tr class="">
							<td>&nbsp;</td>				
						</tr>							
						<tr class="">
							<td>&nbsp;</td>				
						</tr>							
						<tr class="">
							<td>&nbsp;</td>				
						</tr>							
					</table></td>		
				</tr>
				<tr class="">
					<td colspan="2" class="TableBorder"><%=cdo.getColValue("tipo_docto_desc")%>:<%=cdo.getColValue("printed_no")%></td>
				</tr>						
				<tr>
          <td colspan="2" class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
							<tr class="">
                <td width="10%" align="center">CANTIDAD</td>
                <td width="70%" align="center">DESCRIPCION</td>
                <td width="10%" align="center">PRECIO</td>
                <td width="10%" align="center">SUBTOTAL</td>
              </tr>
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
                <td align="right"><%=cd.getColValue("itemUnitPrice")%></td>
              </tr>
              <%
							subtotal+=Double.parseDouble(cd.getColValue("itemUnitPrice"));
							}
							if(subtotal!=0.00){
							%>
              <tr class="">
                <td colspan = "1">&nbsp;</td>
                <td>SUBTOTAL</td>
								<td>&nbsp;</td>
                <td align="right"><%=CmnMgr.getFormattedDecimal(subtotal)%></td>
              </tr>
							<%}
							if(!cdo.getColValue("total_discount").equals("0.00")){
							%>
              <tr class="">
                <td colspan = "1">&nbsp;</td>
                <td>DESC</td>
								<td>&nbsp;</td>
                <td align="right">-<%=CmnMgr.getFormattedDecimal(cdo.getColValue("total_discount"))%></td>
              </tr>
							<%}%>
            </table></td>
        </tr>
				<tr class="">
					<td width="50%" class="TableBorder">
						<table align="center" width="99%" cellpadding="0" cellspacing="1">
							<tr>
                <td width="60%" align="left">EXENTO</td>
                <td width="40%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("sub_total"))%></td>
              </tr>
							<tr>
                <td width="60%" align="left">SUBTOTAL A (7.00%)</td>
                <td width="40%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("sub_total_gravable"))%></td>
              </tr>
              <tr class="">
                <td width="60%" align="left">SUBTOTAL DESCUENTOS</td>
                <td width="40%" align="right"><%=(cdo.getColValue("total_discount").equals("0.00")?"":"-"+CmnMgr.getFormattedDecimal(cdo.getColValue("total_discount")))%></td>
              </tr>
            </table>
					</td>
					<td width="50%" class="TableBorder">
						<table align="center" width="99%" cellpadding="0" cellspacing="1">
							<tr>
                <td width="60%" align="left">SUBTOTAL</td>
                <td width="40%" align="right"><%=CmnMgr.getFormattedDecimal((Double.parseDouble(cdo.getColValue("sub_total")) +Double.parseDouble(cdo.getColValue("sub_total_gravable")) - Double.parseDouble(cdo.getColValue("total_discount"))))%></td>
              </tr>
							<tr>
                <td width="60%" align="left">ITBM A (7.00%)</td>
                <td width="40%" align="right"><%=CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("sub_total_gravable"))*0.07)%></td>
              </tr>
							<tr>
                <td width="60%" align="left"><b>TOTAL</td>
                <td width="40%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("net_amount"))%></td>
              </tr>
            </table></td>
        </tr>

				<tr class="">
					<td width="50%" class="TableBorder">
						<table align="center" width="99%" cellpadding="0" cellspacing="1">
							<tr>
								<td width="60%" align="left">:</td>
								<td width="40%" align="right">0.00</td>
							</tr>
							<tr class="">
								<td width="60%" align="left">:</td>
								<td width="40%" align="right">0.00</td>
							</tr>
							<tr class="">
								<td width="60%" align="left">:</td>
								<td width="40%" align="right">0.00</td>
							</tr>
						</table>
					</td>
					<td width="50%" class="TableBorder">
						<table align="center" width="99%" cellpadding="0" cellspacing="1">
							<tr>
								<td width="60%" align="left">EFECTIVO</td>
								<td width="40%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("net_amount"))%></td>
							</tr>
						</table>
					</td>
				</tr>

				<tr class="" align="center">
					<td colspan = "2" align="right">
						<%=fb.button("cancel","Cerrar",false,false,"Text10",null,"onClick=\"javascript:window.close();\"")%>
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