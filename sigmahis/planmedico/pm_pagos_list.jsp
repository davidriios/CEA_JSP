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
	String appendFilter = ""; 
	
	if (!fechaIni.trim().equals("") && !fechaFin.trim().equals("")) appendFilter += " and trunc(p.fecha) between to_date('"+fechaIni+"','dd/mm/yyyy') and to_date('"+fechaFin+"','dd/mm/yyyy') ";
	
	if (clientId.trim().equals("")) throw new Exception("clientId: Parámetro inválido. Contacte un administrador!");
	
	ArrayList al = SQLMgr.getDataList("select p.codigo, dp.fac_codigo, p.recibo, p.caja, p.ref_id, p.turno, c.descripcion caja_desc, dp.doc_a_nombre, p.pago_total, decode(dp.pago_por,'F','FACTURA','D','DEPOSITO','R','REMANENTE','N/A') pago_por, to_char(p.fecha ,'dd/mm/yyyy') fecha, cj.nombre cajero from tbl_cja_detalle_pago dp , tbl_cja_transaccion_pago p, tbl_cja_cajas c /*--------------*/ ,tbl_cja_cajas_x_cajero cc, tbl_cja_cajera cj, tbl_cja_turnos t, tbl_cja_turnos_x_cajas tc where dp.compania = p.compania and dp.codigo_transaccion = p.codigo  and dp.tran_anio = p.anio and p.tipo_cliente = 'O' and p.ref_type = (select param_value from tbl_sec_comp_param where param_name = 'PM_TIPO_REF') and dp.anulada = 'N' and c.codigo = p.caja and c.compania = p.compania  /*--------------*/ and cc.cod_cajero = cj.cod_cajera and t.cja_cajera_cod_cajera = cj.cod_cajera and tc.compania = t.compania and tc.cod_turno = t.codigo and tc.cod_caja = c.codigo and tc.compania = c.compania and rownum = 1 and  cc.cod_caja = p.caja and cc.compania_caja = c.compania and t.codigo = p.turno  and p.ref_id = "+clientId+appendFilter+" order by p.fecha desc");
	
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
					<tr class="" align="center">
						<td>
							<table width="99%" border="0" align="center"  cellpadding="0" cellspacing="1">
							
							    <tr class="TextHeader">
									<td width="7%">#Trans</td>
									<td width="10%" align="center"># Factura</td>
									<td width="23%">Nombre Cliente</td>
									<td width="7%" align="center">F.Pago</td>
									<td width="16%">Caja</td>
									<td width="15%">Cajer@</td>
									<td width="5%" align="center">Turno</td>
									<td width="10%" align="center">PagoPor</td>
									<td width="7%" align="right">Monto</td>
								</tr>
								
								<%								  
									for (int f = 0; f < al.size(); f++){
										CommonDataObject cdo = (CommonDataObject) al.get(f);
										String color = "TextRow02";
										if (f % 2 == 0) color = "TextRow01";
										%>
							
										<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
											<td><%=cdo.getColValue("codigo")%></td>
											<td align="center"><%=cdo.getColValue("fac_codigo")%></td>
											<td>[<%=cdo.getColValue("ref_id")%>]<%=cdo.getColValue("doc_a_nombre")%></td>
											<td align="center"><%=cdo.getColValue("fecha")%></td>
											<td>[<%=cdo.getColValue("caja")%>]<%=cdo.getColValue("caja_desc")%></td>
											<td><%=cdo.getColValue("cajero")%></td>
											<td align="center"><%=cdo.getColValue("turno")%></td>
											<td align="center"><%=cdo.getColValue("pago_por")%></td>
											<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("pago_total"))%></td>
										</tr>
								<%  
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