<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%

	SecMgr.setConnection(ConMgr);
	if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

	SQLMgr.setConnection(ConMgr);
	CmnMgr.setConnection(ConMgr);

	UserDet = SecMgr.getUserDetails(session.getId());
	session.setAttribute("UserDet",UserDet);
	issi.admin.ISSILogger.setSession(session);
	
	String compId=(String) session.getAttribute("_companyId");
	String fg = request.getParameter("fg");
	String clientId = (request.getParameter("clientId")==null?"":request.getParameter("clientId"));
	String fechaIni = request.getParameter("fechaIni") == null?"":request.getParameter("fechaIni");
	String fechaFin = request.getParameter("fechaFin") == null?"":request.getParameter("fechaFin");
	String clientName = request.getParameter("clientName") == null?"":request.getParameter("clientName");
		
	if (clientId.trim().equals("")) throw new Exception("clientId: Parámetro inválido. Contacte un administrador!");
	
	StringBuffer sbSql = new StringBuffer();
	
	sbSql.append("select 'FAC' doc, d_fac.fac_codigo fac_cod, 'Plan # '||num_contrato_alq||' para el mes de '||(case to_number(mes_alq) when 1 then 'Enero' when 2 then 'Febrero' when 3 then 'Marzo' when 4 then 'Abril' when 5 then 'Mayo' when 6 then 'Junio' when 7 then 'Julio' when 8 then 'Agosto' when 9 then 'Septiembre' when 10 then 'Octubre' when 11 then 'Noviembre' when 12 then 'Diciembre' end)|| ' de ' || anio_alq fac_desc, to_char(fac.fecha,'dd/mm/yyyy') fecha_dsp, trunc(fac.fecha) fecha, sum(d_fac.monto) fac_monto, 0 pago_total, null cod_pago from tbl_fac_factura fac, tbl_fac_detalle_factura d_fac where fac.codigo = d_fac.fac_codigo and fac.compania = d_fac.compania and fac.facturar_a = 'O' and fac.facturado_por = 'PLAN_MEDICO' and fac.estatus <> 'A' and fac.cod_otro_cliente = '");
	sbSql.append(clientId);
	sbSql.append("' and fac.compania = ");
	sbSql.append(compId);
	sbSql.append(" and fac.cliente_otros = (select param_value from tbl_sec_comp_param where param_name = 'TIPO_CLTE_PLAN_MEDICO' and compania= ");
	sbSql.append(compId);
	sbSql.append(")");
	
	if (!fechaIni.trim().equals("") && !fechaFin.trim().equals("")) {
		sbSql.append(" and trunc(fac.fecha) between to_date('");
		sbSql.append(fechaIni);
		sbSql.append("','dd/mm/yyyy')");
		sbSql.append(" and to_date('");
		sbSql.append(fechaFin);
		sbSql.append("','dd/mm/yyyy')");
	}
	
	sbSql.append(" group by 'FAC', d_fac.fac_codigo, fac.num_contrato_alq, fac.mes_alq, fac.anio_alq, to_char (fac.fecha, 'dd/mm/yyyy'), trunc (fac.fecha), 0, null ");

	sbSql.append(" order by 2,1,4 ");

	ArrayList al = SQLMgr.getDataList(sbSql.toString());
	
	System.out.println("THEBRAIN>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> al.size() = "+al.size());

if(request.getMethod().equalsIgnoreCase("GET")){

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function doAction(){
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}
</script>
</head>
<body bgcolor="#ffffff" topmargin="0" leftmargin="0" onLoad="javascript:doAction();">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clientId",clientId)%>
	<table align="center" width="100%" cellpadding="0" cellspacing="0">
		<tr>
			<td class="TableBorder">
				<table align="center" width="100%" cellpadding="0" cellspacing="0">
						<tr align="center">
						<td>
							<table class="Text10Bold" width="100%" border="0" align="center"  cellpadding="0" cellspacing="1">
							
							<tr class="TextHeader">
							  <td>Cliente:</td>
							  <td colspan="2"><%=clientName%></td>
							  <td>Id Clie:&nbsp;&nbsp;&nbsp;<%=clientId%></td>
							</tr>
							
							    <tr class="TextHeader">
									<td width="10%">#Documento</td>
									<td width="53%">Descripci&oacute;n</td>
									<td width="10%" align="center">Fecha</td>
									<td width="10%" align="right">Facturado</td>
								</tr>
								
								<%								  
									String groupByFact = "";
									double totPagado = 0.0, totFacturado = 0.0, saldo = 0.0, totPagadoF = 0.0, totFacturadoF = 0.0;
									
									for (int f = 0; f < al.size(); f++){
										CommonDataObject cdo = (CommonDataObject) al.get(f);
										String color = "TextRow02";
										if (f % 2 == 0) color = "TextRow01";
								   totFacturado += Double.parseDouble(cdo.getColValue("fac_monto")); 
								   totPagado += Double.parseDouble(cdo.getColValue("pago_total"));
								   saldo = totFacturado-totPagado;
										%>
			
										<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
											<td><%=(cdo.getColValue("doc").equalsIgnoreCase("PAG") || cdo.getColValue("doc").equalsIgnoreCase("PAGNA")?cdo.getColValue("cod_pago"):cdo.getColValue("fac_cod"))%></td>
											<td><%=cdo.getColValue("fac_desc")%></td>
											<td align="center"><%=cdo.getColValue("fecha_dsp")%></td>
											<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("fac_monto"))%></td>
										</tr>
								<%  
								
								   groupByFact = cdo.getColValue("fac_cod");
								   
								   totFacturadoF += Double.parseDouble(cdo.getColValue("fac_monto"));
								   totPagadoF += Double.parseDouble(cdo.getColValue("pago_total"));
								   }
								   if (al.size() > 0) {
								   saldo = totFacturado - totPagado;
								%>
								<tr align="right" class="RedText">
									<td colspan="1">TOTALES EN FACTURA</td>
									<td align="right"><%=CmnMgr.getFormattedDecimal(totFacturadoF)%></td>
									<td align="right"><%=CmnMgr.getFormattedDecimal(totPagadoF)%></td>
									<td align="right"><%=CmnMgr.getFormattedDecimal((totFacturadoF-totPagadoF))%></td>
								</tr>
								<%}else{%>
								<%}%>
							</table>
						</td>
					</tr>			
				</table>
			</td>
		</tr>
	</table>
<%=fb.formEnd(true)%>
<%
%>
</body>
</html>
<%
}//post
%>