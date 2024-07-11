<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String key = "";
StringBuffer sql = new StringBuffer();
String change = request.getParameter("change");
String codigo = request.getParameter("codigo");
String fp = request.getParameter("fp");

int lastLineNo = 0;
if(fp == null)fp="";
if (request.getParameter("lastLineNo") != null) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	    HashDet.clear();
		
				
		sql.append("select z.*, (nvl(z.grang_total, 0) - nvl(z.facpagos, 0) + nvl(z.facajustes, 0)) monto_pendiente from (select a.compania, a.codigo, a.facturar_a, decode(a.facturar_a, 'E', 'EMPRESA', 'P', 'PACIENTE', 'O', 'OTROS') facturar_a_desc, a.lista, a.admi_secuencia,a.numero_factura, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.tipo, a.estatus, decode(a.estatus, 'P', 'PENDIENTE', 'C', 'CANCELADA', 'A', 'ANULADA') estatus_desc, a.monto_total, a.monto_descuento, a.cod_empresa, a.cliente_otros, a.anio_cargo, a.codigo_cargo, a.tipo_cargo, a.ref_cta_appx, a.itbm, a.subtotal, to_char(a.fecha_anulacion, 'dd/mm/yyyy') fecha_anulacion, to_char(a.fecha_envio, 'dd/mm/yyyy') fecha_envio, a.monto_paciente, a.total_honorarios, a.grang_total, a.anio, a.ref_empresa, a.tipo_cobro, a.num_contrato_alq, a.facturado_por, a.cliente_alq, a.total_pago_cia_1, a.distribuido, a.tipo_cobertura, a.ref_empresa_ab, a.monto_descuento2, a.codigo_beneficio, a.f_anio, a.estatus_cta, a.mes_alq, a.anio_alq, a.pase, a.pase_k, a.webclaim, a.elegible, a.comentario, a.saldo, a.enviado, a.pagado, a.convenio, a.tipo_plan, a.categoria_admi, a.tipo_admi, a.clasif_admi, a.clasif_factura, a.ubicacion, a.cuenta_i, decode(a.cuenta_i, 'I', 'CUENTAS INCOBRABLES') desc_cuenta_i, a.clasif_factura_ref, a.cod_empresa_cambio, to_char(a.fecha_asignacion, 'dd/mm/yyyy') fecha_asignacion, decode(a.facturar_a,'O',a.cod_otro_cliente,a.pac_id)pac_id, decode(a.facturar_a,'O',getNombreCliente(a.compania,a.cliente_otros,a.cod_otro_cliente),b.nombre_paciente)nombre_paciente, nvl(c.nombre, ' ') nombre_empresa, d.nombre nombre_compania,nvl((case when a.facturar_a in ('E', 'O') then (select sum(monto) from tbl_cja_detalle_pago cdp,tbl_cja_transaccion_pago ctp where cdp.fac_codigo = a.codigo and cdp.compania = a.compania and cdp.codigo_transaccion = ctp.codigo and cdp.tran_anio = ctp.anio and cdp.compania = ctp.compania and ctp.rec_status <> 'I') when a.facturar_a = 'P' then (select sum(d.monto) from tbl_cja_transaccion_pago p, tbl_cja_detalle_pago d where d.fac_codigo = a.codigo and d.compania = a.compania  and d.codigo_transaccion = p.codigo  and d.tran_anio = p.anio and d.compania = p.compania and d.cod_rem is null and p.rec_status <> 'I' ) else (select sum(d.monto) from tbl_cja_transaccion_pago p, tbl_cja_detalle_pago d where d.fac_codigo = a.codigo and p.compania = a.compania and d.codigo_transaccion = p.codigo and d.tran_anio = p.anio and d.compania = p.compania and d.cod_rem is null and p.rec_status <> 'I')  end), 0) facpagos, nvl((select sum(decode(z.lado_mov,'D',z.monto,'C',decode(z.tipo_ajuste,'68',0,(-1*z.monto)))) ajuste from vw_con_adjustment_gral z where  z.factura = a.codigo and z.compania = a.compania), 0) +(select nvl(sum(decode(z.doc_type, 'NDB', z.net_amount,'NCR',-z.net_amount)),0) v_monto_ndnc_pos from tbl_fac_trx z where exists (select null from tbl_fac_trx x where x.other3 = a.codigo and x.doc_type = 'FAC' and x.doc_id = z.reference_id) and z.company_id =a.compania and z.doc_type in ('NDB', 'NCR') and z.status = 'O') facajustes from tbl_fac_factura a, vw_adm_paciente b, tbl_adm_empresa c, tbl_sec_compania d where a.pac_id = b.pac_id(+) and a.cod_empresa = c.codigo(+) and a.compania = d.codigo and a.compania = ");
		sql.append(session.getAttribute("_companyId"));
		sql.append(" and a.codigo = '");
		sql.append(codigo);
		sql.append("') z");
		cdo = SQLMgr.getData(sql.toString());

		if (change == null && !cdo.getColValue("facturar_a").trim().equals("O")){
		sql = new StringBuffer();
			if(cdo.getColValue("facturar_a") != null && !cdo.getColValue("facturar_a").trim().equals("")&& !cdo.getColValue("facturar_a").trim().equals("O")){
			sql.append("select a.secuencia, to_char(a.fecha_ingreso, 'dd/mm/yyyy') fecha_ingreso, a.dias_estimados, a.dias_hospitalizados, a.estado, decode(a.estado, 'E', 'Espera', 'I', 'Inactiva', 'A', 'Activa', 'C', 'Cancelada', 'S', 'Especial') estado_desc, a.categoria, decode(a.categoria, 1, 'Hospitalizado', 2, 'Ambulatorio') categoria_desc, a.tipo_admision, a.num_factura, a.conta_cred, decode(a.conta_cred, 'C', 'Contado', 'R', 'Credito') conta_cred_desc, c.descripcion as centroServicio from tbl_adm_admision a, tbl_cds_centro_servicio c where  c.codigo = a.centro_servicio and a.pac_id = ");
			sql.append(cdo.getColValue("pac_id"));
			sql.append(" and a.compania = ");
			sql.append(session.getAttribute("_companyId"));
			if(fp.trim().equals("CXPHON")){sql.append(" and a.secuencia ="); sql.append(cdo.getColValue("admi_secuencia"));}
			sql.append(" and a.estado in ('A','E','I') order by a.fecha_ingreso desc ");
			al = SQLMgr.getDataList(sql.toString());}

			HashDet.clear();
			lastLineNo = al.size();
			for (int i = 1; i <= al.size(); i++)
			{
			  if (i < 10) key = "00" + i;
			  else if (i < 100) key = "0" + i;
			  else key = "" + i;

			  HashDet.put(key, al.get(i-1));
		    }
		}
%>
<html>
<head>
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title="Facturas con Pagos - "+document.title;

function saveMethod()
{
  if (formFacturaValidation())
  {
     window.frames['itemFrame'].formFactura.baction.value = "Guardar";
     window.frames['itemFrame'].doSubmit();
  }
}
function pagoAseg()
{
	var cod_empresa = document.formFactura.cod_empresa.value;
	if(cod_empresa=='') alert('No empresa');
	else abrir_ventana1('../caja/consul_pagos_x_aseg.jsp?fg=empresa&cod_empresa='+cod_empresa+'&fp=<%=fp%>&documento=<%=codigo%>');
}
function pagoFact(facturarA)
{
	var codigo = '<%=codigo%>';
	if(codigo=='') alert('No empresa');
	else abrir_ventana1('../caja/consul_pagos_det.jsp?codigo='+codigo+'&factA='+facturarA);
}
function ajuste()
{
	var codigo = '<%=codigo%>';
	if(codigo=='') alert('No empresa');
	else abrir_ventana1('../caja/consul_ajustes.jsp?codigo='+codigo);
}
function pagoPaciente()
{
	var pac_id = document.formFactura.pac_id.value;
	if(pac_id=='') alert('No paciente');
	else abrir_ventana1('../caja/consul_pagos_x_aseg.jsp?fg=paciente&pac_id='+pac_id+'&fp=<%=fp%>&documento=<%=codigo%>');
}
function printFact()
{
	var pac_id = document.formFactura.pac_id.value;
	var admi_secuencia = document.formFactura.admi_secuencia.value;
	var codigo = '<%=codigo%>';
	abrir_ventana1('../facturacion/print_estado_cargo_det.jsp?pacId='+pac_id+'&noSecuencia='+admi_secuencia+'&factId='+codigo);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CAJA - CONSULTA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
        <tr>
          <td><table align="center" width="100%" cellpadding="0" cellspacing="1">
              <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
              <%fb = new FormBean("formFactura",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
              <%=fb.formStart(true)%> <%=fb.hidden("errCode","")%> <%=fb.hidden("errMsg","")%>
			  <%=fb.hidden("fp",""+fp)%>
              <tr class="TextRow02">
                <td colspan="2">&nbsp;</td>
              </tr>
              <tr>
                <td colspan="2" onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
                    <tr class="TextPanel">
                      <td width="95%">&nbsp;<cellbytelabel>Facturas</cellbytelabel></td>
                      <td width="5%" align="right">[<font face="Courier New, Courier, mono">
                        <label id="plus0" style="display:none">+</label>
                        <label id="minus0">-</label>
                        </font>]&nbsp;</td>
                    </tr>
                  </table></td>
              </tr>
              <tr id="panel0">
                <td><table width="100%" cellpadding="1" cellspacing="1">
                    <tr class="TextRow01">
                      <td width="10%"><cellbytelabel>Compa&ntilde;ia</cellbytelabel></td>
                      <td width="40%"><%=cdo.getColValue("compania")%> <%=cdo.getColValue("nombre_compania")%> </td>
                      <td width="10%"><cellbytelabel>Ubicaci&oacute;n</cellbytelabel></td>
                      <td width="15%"><%=cdo.getColValue("ubicacion")%></td>
                    </tr>
                    <tr class="TextRow02">
                      <td><cellbytelabel>Paciente/Cliente</cellbytelabel></td>
                      <td><%=cdo.getColValue("pac_id")%>&nbsp;|&nbsp; <%=cdo.getColValue("nombre_paciente")%> </td>
                      <td><cellbytelabel>Factura</cellbytelabel></td>
                      <td><%=cdo.getColValue("codigo")%></td>
                    </tr>
                    <%=fb.hidden("cod_empresa", cdo.getColValue("cod_empresa"))%>
                    <%=fb.hidden("pac_id", cdo.getColValue("pac_id"))%>
                    <%=fb.hidden("admi_secuencia", cdo.getColValue("admi_secuencia"))%>
                    <tr class="TextRow01">
                      <td><cellbytelabel>Empresa</cellbytelabel></td>
                      <td><%=cdo.getColValue("cod_empresa")%>&nbsp;-&nbsp; <%=cdo.getColValue("nombre_empresa")%> </td>
                      <td><cellbytelabel>Fecha</cellbytelabel></td>
                      <td><%=cdo.getColValue("fecha")%></td>
                    </tr>
                    <tr class="TextRow02">
                      <td><cellbytelabel>Tipo Cuenta</cellbytelabel></td>
                      <td><%=cdo.getColValue("desc_cuenta_i")%></td>
                      <td><cellbytelabel>Desc.</cellbytelabel></td>
                      <td><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_descuento"))%></td>
                    </tr>
                    <tr class="TextRow01">
                      <td><cellbytelabel>Estatus</cellbytelabel></td>
                      <td><%=cdo.getColValue("estatus_desc")%></td>
                      <td><cellbytelabel>Facturar a</cellbytelabel></td>
                      <td><%=cdo.getColValue("facturar_a_desc")%></td>
                    </tr>
                  </table></td>
                <td valign="top"><table width="100%" cellpadding="0" cellspacing="0">
                    <tr class="TextHeader02" height="20">
                      <td align="right"><cellbytelabel>Gran Total</cellbytelabel></td>
                      <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("grang_total"))%>&nbsp;&nbsp;</td>
                    </tr>
                    <tr class="TextHeader02" height="20">
                      <td align="right"><cellbytelabel>Ajustes</cellbytelabel></td>
                      <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("facajustes"))%>&nbsp;&nbsp;</td>
                    </tr>
                    <tr class="TextHeader02" height="20">
                      <td align="right"><cellbytelabel>Pagos</cellbytelabel></td>
                      <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("facpagos"))%>&nbsp;&nbsp;</td>
                    </tr>
                    <tr class="TextHeader02" height="20">
                      <td align="right"><cellbytelabel>Monto Pendiente</cellbytelabel></td>
                      <td align="right" style="border-top:#FFFFFF groove"><font class="RedTextBold"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_pendiente"))%></font>&nbsp;&nbsp;</td>
                    </tr>
                  </table></td>
              </tr>

              <tr align="right" class="TextRow02">
                <td colspan="2">
								<a href="javascript:printFact();"><img src="../images/print_bill_details.gif" border="0" height="24" width="24" title="Imprimir"></a>&nbsp;&nbsp;&nbsp;
								<%=(!cdo.getColValue("facturar_a").trim().equals("O"))?fb.button("btnPagoAseg","Pagos Aseguradora",false,false,null,null,"onClick=\"javascript:pagoAseg()\""):""%>
								<%=fb.button("btnPagoFact","Pagos Factura",false,false,null,null,"onClick=\"javascript:pagoFact('"+cdo.getColValue("facturar_a")+"')\"")%>
								<%=fb.button("btnAjuste","Ajustes",false,false,null,null,"onClick=\"javascript:ajuste()\"")%>
								<%=(!cdo.getColValue("facturar_a").trim().equals("O"))?fb.button("btnPagoPaciente","Pagos Paciente",false,false,null,null,"onClick=\"javascript:pagoPaciente()\""):""%>
                </td>
              </tr>
			  <%if(!cdo.getColValue("facturar_a").trim().equals("O")){%>
              <tr>
                <td colspan="2" onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
				 <table width="100%" cellpadding="1" cellspacing="0">
                    <tr class="TextPanel">
                      <td width="95%">&nbsp;<cellbytelabel>Detalle de Facturas con Pagos</cellbytelabel></td>
                      <td width="5%" align="right">[<font face="Courier New, Courier, mono">
                        <label id="plus1" style="display:none">+</label>
                        <label id="minus1">-</label>
                        </font>]&nbsp;</td>
                    </tr>
                  </table></td>
              </tr>
              <tr id="panel1">
                <td colspan="2"><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="50" scrolling="no" src="../caja/facturapagos_detail.jsp"></iframe></td>
              </tr><%}%>
              <tr class="TextRow02">
                <td colspan="2" align="right"><%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
              </tr>
              <%=fb.formEnd(true)%>
              <!-- ================================   F O R M   E N D   H E R E   ================================ -->
            </table></td>
        </tr>
      </table></td>
  </tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
  String errCode = request.getParameter("errCode");
  String errMsg = request.getParameter("errMsg");
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	window.location = '<%=request.getContextPath()%>/caja/factura_pagos.jsp'
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
