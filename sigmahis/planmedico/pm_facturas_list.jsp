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

	String compId = (String) session.getAttribute("_companyId");
	String fg = request.getParameter("fg");
	String clientId = (request.getParameter("clientId")== null?"":request.getParameter("clientId"));
	String fechaIni = request.getParameter("fechaIni") == null?"":request.getParameter("fechaIni");
	String fechaFin = request.getParameter("fechaFin") == null?"":request.getParameter("fechaFin");
	String estadoFact = request.getParameter("estadoFact") == null?"":request.getParameter("estadoFact");

	StringBuffer sbSql = new StringBuffer();

	if (clientId.trim().equals("")) throw new Exception("clientId: Parámetro inválido. Contacte un administrador!");

	sbSql.append("select f1.id_fac , lpad(f1.id_fac,10,0) id_fac_dsp, f1.id_clie,f1.id_sol_contrato,f1.fecha_ini_plan,f1.monto,f1.fecha_pago,to_char(f1.fecha_creacion,'dd/mm/yyyy') fecha_creacion,'SISTEMA' usuario_creacion,f1.fecha_modificacion,f1.usuario_modificacion,f1.estado,f1.observacion,to_char(f1.fecha_prox_factura,'dd/mm/yyyy') fecha_prox_factura,f1.nombre_cliente,f1.descripcion_factura,f1.id_beneficiario,f1.nombre_beneficiario,f1.tipo , extra.descripcion fac_estado, (select p.descripcion from tbl_pm_afiliado p where p.id = (select afiliados from tbl_pm_solicitud_contrato sc where sc.id = f1.id_sol_contrato)) plan_desc from tbl_pm_factura f1,");

	sbSql.append(" (select r.id, ttp.codigo, ttp.descripcion from tbl_cja_tipo_transaccion ttp, tbl_cja_detalle_pago dp, tbl_cja_transaccion_pago tp, tbl_pm_regtran r where ttp.codigo = dp.tipo_transaccion and tp.codigo = dp.codigo_transaccion and tp.compania = dp.compania and tp.anio = dp.tran_anio and tp.tipo_cliente = 'O' and tp.compania = r.compania and tp.anio = r.anio_ref and tp.codigo = r.id_ref) extra ");

	sbSql.append(" where f1.id_clie = ");
	sbSql.append(clientId);

	sbSql.append(" /**/ and f1.id_fac = extra.id(+) /**/ ");

	if (!estadoFact.equals("")) {
		sbSql.append(" and extra.codigo = ");
		sbSql.append(estadoFact);
	}

	if (!fechaFin.trim().equals("") && !fechaIni.trim().equals("")){
	   sbSql.append(" and trunc(f1.fecha_creacion) between to_date('");
	   sbSql.append(fechaIni);
	   sbSql.append("','dd/mm/yyyy') and to_date('");
	   sbSql.append(fechaFin);
	   sbSql.append("','dd/mm/yyyy')");
	}

	sbSql.append(" and (select count(s.id_cliente) from  tbl_pm_solicitud_contrato s, tbl_pm_sol_contrato_det d where  s.fecha_ini_plan is not null and d.estado = 'A' and s.id = d.id_solicitud and s.id_cliente = d.id_cliente and d.id_cliente = ");

	sbSql.append(clientId);

	sbSql.append(" ) > 0 ");

	sbSql.append(" order by f1.id_clie, f1.id_sol_contrato ");

	ArrayList al = SQLMgr.getDataList(sbSql.toString());

	System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> al.size() = "+al.size());

if(request.getMethod().equalsIgnoreCase("GET")){

%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function doAction(){
	if (parent.adjustIFrameSize)parent.adjustIFrameSize(window);
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

								<%
									String grpByClie = "", grpByPlan = "";

									for (int f = 0; f < al.size(); f++){
										CommonDataObject cdo = (CommonDataObject) al.get(f);
										String color = "TextRow02";
										if (f % 2 == 0) color = "TextRow01";

										if (!grpByClie.equalsIgnoreCase(cdo.getColValue("id_clie"))){%>
										  <tr class="TextHeader01">
										  	<td colspan="7">Responsable: <%=cdo.getColValue("nombre_cliente")%></td>
										  </tr>
										<%}%>
										<%
										if (!grpByPlan.equalsIgnoreCase(cdo.getColValue("id_sol_contrato"))){%>
										  <tr class="TextHeader01">
										  	<td colspan="7">Plan: <%=cdo.getColValue("plan_desc")%></td>
										  </tr>
										  <tr class="TextHeader">
											<td width="10%"># Factura</td>
											<td width="30%">Descripci&oacute;n</td>
											<td width="10%" align="right">Monto</td>
											<td width="10%" align="center">F.Creaci&oacute;n</td>
											<td width="20%">Creada por</td>
											<td width="10%" align="center">Estado</td>
											<td width="10%" align="center">Prox. Fac.</td>
										</tr>
										<%}%>

										<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
											<td><%=cdo.getColValue("id_fac_dsp")%></td>
											<td><%=cdo.getColValue("descripcion_factura")%></td>
											<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%></td>
											<td align="center"><%=cdo.getColValue("fecha_creacion")%></td>
											<td><%=cdo.getColValue("usuario_creacion")%></td>
											<td align="center"><%=cdo.getColValue("fac_estado")%></td>
											<td align="center"><%=cdo.getColValue("fecha_prox_factura")%></td>
										</tr>
								<%
								        grpByClie = cdo.getColValue("id_clie");
										grpByPlan = cdo.getColValue("id_sol_contrato");
								   }
								%>
							</table>
						</td>
					</tr>
				</table>
			</td>
		</tr>
					<tr class="" align="center">
						<td>&nbsp;
						</td>
					</tr>
					<tr class="" align="center">
						<td>&nbsp;
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
