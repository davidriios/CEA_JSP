<%//@ page errorPage="../error.jsp"%>
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
	sbSql.append("select '01/'||to_char(sysdate, 'mm/yyyy') fecha_ini, to_char(last_day(sysdate), 'dd/mm/yyyy') fecha_fin from dual");
	
	CommonDataObject _si = SQLMgr.getData(sbSql.toString());
	if(fechaIni.equals("")) fechaIni = _si.getColValue("fecha_ini");
	if(fechaFin.equals("")) fechaFin = _si.getColValue("fecha_fin");
	
	sbSql = new StringBuffer();
	
	sbSql.append("select nvl(sum(monto_fact)-sum(monto_trx), 0) saldo_inicial from (select monto monto_fact, 0 monto_trx from tbl_pm_factura where id_clie = ");
	sbSql.append(clientId);
	if (!fechaIni.trim().equals("") && !fechaFin.trim().equals("")) {
		sbSql.append(" and trunc(fecha) < to_date('");
		sbSql.append(fechaIni);
		sbSql.append("','dd/mm/yyyy')");
	}
	sbSql.append(" union all ");
	sbSql.append(" select 0, monto*periodo monto_trx from tbl_pm_regtran_det where estado = 'A' and id_cliente = ");
	sbSql.append(clientId);
	if (!fechaIni.trim().equals("") && !fechaFin.trim().equals("")) {
		sbSql.append(" and trunc(fecha_creacion) < to_date('");
		sbSql.append(fechaIni);
		sbSql.append("','dd/mm/yyyy')");
	}
	sbSql.append(")");
	_si = new CommonDataObject();
	_si = SQLMgr.getData(sbSql.toString());
	
	sbSql = new StringBuffer();
	/*
	sbSql.append("select 'FAC' doc, ' ' fac_cod, 'Factura plan #'||f.id_sol_contrato||' para el mes de '|| trim(to_char(to_date('01/'||lpad(f.mes, 2, '0')||'/'||f.anio,'dd/mm/yyyy'), 'Month','NLS_DATE_LANGUAGE=SPANISH'))||' de '||f.anio fac_desc, f.anio, f.mes, to_char(f.fecha, 'dd/mm/yyyy') fecha_dsp, trunc(f.fecha) fecha, sum(f.monto) fac_monto, sum(0) pago_total, '' cod_pago from tbl_pm_factura f where estado = 'A'");
	sbSql.append(" and f.id_clie = ");
	sbSql.append(clientId);
	if (!fechaIni.trim().equals("") && !fechaFin.trim().equals("")) {
		sbSql.append(" and trunc(f.fecha) between to_date('");
		sbSql.append(fechaIni);
		sbSql.append("','dd/mm/yyyy')");
		sbSql.append(" and to_date('");
		sbSql.append(fechaFin);
		sbSql.append("','dd/mm/yyyy')");
	}

	sbSql.append(" group by 'FAC', '', 'Factura plan #'||f.id_sol_contrato||' para el mes de '|| trim(to_char(to_date('01/'||lpad(f.mes, 2, '0')||'/'||f.anio,'dd/mm/yyyy'), 'Month','NLS_DATE_LANGUAGE=SPANISH'))||' de '||f.anio, to_char(f.fecha, 'dd/mm/yyyy') , trunc(f.fecha) , 0, f.anio, f.mes ");
	*/
	sbSql.append("select 'FAC' doc, codigo fac_cod, 'Factura plan #' || f.num_contrato_alq || ' para el mes de ' || trim (to_char (to_date ('01/' || lpad (f.mes_alq, 2, '0') || '/' || f.anio_alq, 'dd/mm/yyyy'), 'Month', 'NLS_DATE_LANGUAGE=SPANISH')) || ' de ' || f.anio_alq fac_desc, f.anio_alq, to_number(f.mes_alq) mes, to_char (f.fecha, 'dd/mm/yyyy') fecha_dsp, trunc (f.fecha) fecha, f.grang_total fac_monto, 0 pago_total, '' cod_pago from tbl_fac_factura f where estatus != 'A' and facturar_a = 'O' and f.cod_otro_cliente = '");
		sbSql.append(clientId);
		sbSql.append("'");
	if (!fechaIni.trim().equals("") && !fechaFin.trim().equals("")) {
		sbSql.append(" and trunc (f.fecha) between to_date ('");
		sbSql.append(fechaIni);
		sbSql.append("', 'dd/mm/yyyy') and to_date ('");
		sbSql.append(fechaFin);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	sbSql.append(" union all ");
	sbSql.append("select 'PAG', (select join(cursor(select id_fac from tbl_pm_factura where id_regtran = r.id), ', ') from dual) fac_cod, 'PAGO', r.anio, r.mes, to_char(r.fecha_creacion, 'dd/mm/yyy') fecha_dsp, (r.fecha_creacion) fecha, 0, sum(dr.monto*nvl(dr.periodo,1)), (select recibo from tbl_cja_transaccion_pago tp where tp.compania = r.compania and tp.anio = r.anio_ref and tp.codigo = r.id_ref) cod_pago from tbl_pm_regtran r, tbl_pm_regtran_det dr where r.id = dr.id and r.tipo_trx = 'RECIBO' and dr.id_cliente = ");
	sbSql.append(clientId);	
	sbSql.append("");
	
	if (!fechaIni.trim().equals("") && !fechaFin.trim().equals("")) {
		sbSql.append(" and trunc(r.fecha_creacion) between to_date('");
		sbSql.append(fechaIni);
		sbSql.append("','dd/mm/yyyy')");
		sbSql.append(" and to_date('");
		sbSql.append(fechaFin);
		sbSql.append("','dd/mm/yyyy')");
	}
	
	sbSql.append(" group by 'PAG', r.compania, r.anio_ref, r.id_ref, r.id, 'PAGO', to_char(r.fecha_creacion, 'dd/mm/yyy'), (r.fecha_creacion), 0, to_char(r.id_ref), r.anio, r.mes");
	sbSql.append(" union all ");
	sbSql.append("select decode(r.tipo_trx, 'ACH', 'ACH', 'TC', 'TARJETA CREDITO', 'M', 'MANUAL'), '' fac_cod, decode(r.tipo_trx, 'ACH', 'ACH', 'TC', 'TARJETA CREDITO', 'M', 'MANUAL'), r.anio, r.mes, to_char (r.fecha_creacion, 'dd/mm/yyyy') fecha_dsp,  (r.fecha_creacion) fecha, 0, sum (decode(dr.tipo_trx, 'M', dr.monto_app, dr.monto*dr.periodo)), to_char (r.id) cod_pago from tbl_pm_regtran r, tbl_pm_regtran_det dr where r.id = dr.id and r.tipo_trx in ('ACH', 'TC', 'M') and r.estado = 'A' and dr.id_cliente = ");
	sbSql.append(clientId);	
	if (!fechaIni.trim().equals("") && !fechaFin.trim().equals("")) {
		sbSql.append(" and trunc(r.fecha_creacion) between to_date('");
		sbSql.append(fechaIni);
		sbSql.append("','dd/mm/yyyy')");
		sbSql.append(" and to_date('");
		sbSql.append(fechaFin);
		sbSql.append("','dd/mm/yyyy')");
	}
	sbSql.append(" group by decode(r.tipo_trx, 'ACH', 'ACH', 'TC', 'TARJETA CREDITO', 'M', 'MANUAL'), '', decode(r.tipo_trx, 'ACH', 'ACH', 'TC', 'TARJETA CREDITO', 'M', 'MANUAL'), to_char (r.fecha_creacion, 'dd/mm/yyyy'),  (r.fecha_creacion), 0, to_char (r.id), r.anio, r.mes");
	sbSql.append(" order by 7, 2,1,4, 5 ");

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
							  <td colspan="4"><%=clientName%></td>
							  <td>Id Clie:&nbsp;&nbsp;&nbsp;<%=clientId%></td>
							</tr>
							<tr class="TextHeader">
									<td width="10%">#Documento</td>
									<td width="53%">Descripci&oacute;n</td>
									<td width="10%" align="center">Fecha</td>
									<td width="10%" align="right">D&eacute;bito</td>
									<td width="10%" align="right">Cr&eacute;dito</td>
									<td width="7%" align="right">Saldo</td>
							</tr>
							<tr class="TextHeader">
									<td colspan="5" align="right">Saldo Inicial:</td>
									<td width="7%" align="right"><%=CmnMgr.getFormattedDecimal(_si.getColValue("saldo_inicial"))%></td>
							</tr>
								
								<%								  
									String groupByFact = "";
									double totPagado = 0.0, totFacturado = 0.0, saldo = Double.parseDouble(_si.getColValue("saldo_inicial")), totPagadoF = 0.0, totFacturadoF = 0.0;
									
									for (int f = 0; f < al.size(); f++){
										CommonDataObject cdo = (CommonDataObject) al.get(f);
										String color = "TextRow02";
										if (f % 2 == 0) color = "TextRow01";
								   totFacturado += Double.parseDouble(cdo.getColValue("fac_monto")); 
								   totPagado += Double.parseDouble(cdo.getColValue("pago_total"));
								   saldo += Double.parseDouble(cdo.getColValue("fac_monto"))-Double.parseDouble(cdo.getColValue("pago_total"));
										
										%>
										<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
											<td><%=(cdo.getColValue("doc").equalsIgnoreCase("PAG") || cdo.getColValue("doc").equalsIgnoreCase("PAGNA") || cdo.getColValue("doc").equalsIgnoreCase("TARJETA CREDITO") || cdo.getColValue("doc").equalsIgnoreCase("ACH") || cdo.getColValue("doc").equalsIgnoreCase("MANUAL")?cdo.getColValue("cod_pago"):cdo.getColValue("fac_cod"))%></td>
											<td><%=cdo.getColValue("fac_desc")%><%=(cdo.getColValue("doc").equalsIgnoreCase("PAG")?"-Fact.:"+cdo.getColValue("fac_cod"):"")%></td>
											<td align="center"><%=cdo.getColValue("fecha_dsp")%></td>
											<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("fac_monto"))%></td>
											<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("pago_total"))%></td>
											<td align="right"><%=CmnMgr.getFormattedDecimal(saldo)%></td>
										</tr>
								<%  
								
								   groupByFact = cdo.getColValue("fac_cod");
								   
								   totFacturadoF += Double.parseDouble(cdo.getColValue("fac_monto"));
								   totPagadoF += Double.parseDouble(cdo.getColValue("pago_total"));
								   }
								   %>
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