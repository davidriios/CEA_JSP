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
String sql = "";
String change = request.getParameter("change");
String codigo = request.getParameter("codigo");
int lastLineNo = 0;

if (request.getParameter("lastLineNo") != null) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
		
		sql = "select a.compania, a.anio, a.codigo, a.tipo_cliente, decode(a.tipo_cliente, 'P', 'P A C I E N T E', 'E', 'E M P R E S A', 'O', 'O T R O S') tipo_cliente_desc, a.codigo_paciente, to_char(b.f_nac, 'dd/mm/yyyy') as f_nac, a.codigo_empresa, a.descripcion, a.pago_total, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.caja, a.usuario_creacion, a.usuario_modificacion, to_char(a.fecha_creacion, 'dd/mm/yyyy hh12:mi am') fecha_creacion, to_char(a.fecha_modificacion, 'dd/mm/yyyy hh12:mi am') fecha_modificacion, a.status, decode(a.status, 'P', 'PENDIENTE', 'C', 'CANCELADA', 'A', 'ANULADA') status_desc, a.impreso, a.turno, a.adelanto, a.tipo_cliente_otros, a.empresa_otros, a.medico_otros, a.cliente_alq, a.num_contrato, a.provincia_emp, a.tmp_desc_alquiler, a.hna_capitation, a.pase, a.anio_trx_fcc, a.recibo, a.nombre, a.anulada, a.nombre_adicional, to_char(a.fecha_anulacion, 'dd/mm/yyyy hh12:mi am') fecha_anulacion, usuario_anulacion, to_char(a.fecha_corte, 'dd/mm/yyyy hh12:mi am') fecha_corte, a.usuario_corte, a.fuera, a.rec_cobrar, a.monto_palabras, a.provincia, a.sigla, a.tomo, a.asiento, a.emp_id, a.pac_id, b.primer_nombre || decode(b.segundo_nombre, null, '', ' ' || b.segundo_nombre) || decode(b.primer_apellido, null, '', ' ' || b.primer_apellido) || decode(b.segundo_apellido, null, '', ' ' || b.segundo_apellido) || decode(b.sexo, 'F', decode(b.apellido_de_casada, null, '', ' ' || b.apellido_de_casada)) nombre_paciente, nvl(c.nombre, ' ') nombre_empresa, d.nombre nombre_compania, e.descripcion nombre_caja from tbl_cja_transaccion_pago a, vw_adm_paciente b, tbl_adm_empresa c, tbl_sec_compania d, tbl_cja_cajas e, tbl_cja_recibos f where a.pac_id = b.pac_id(+) and a.codigo_empresa = c.codigo(+) and a.compania = d.codigo and a.caja = e.codigo and a.compania = e.compania and a.compania = f.compania and a.codigo = f.ctp_codigo and a.anio = f.ctp_anio and f.compania = "+(String) session.getAttribute("_companyId")+ " and f.codigo = '"+codigo+"' /*and a.rec_status <> 'I'*/";

		cdo = SQLMgr.getData(sql);

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
function formaPago()
{
	var codigo = document.formFactura.codigo.value;
	var anio = document.formFactura.anio.value;
	abrir_ventana1('../caja/ver_forma_pago.jsp?fp=recibos_ajustes&codigo='+codigo+'&anio='+anio);
}

function ajuste()
{
	var codigo = '<%=codigo%>';
	var x = getDBData('<%=request.getContextPath()%>','distinct nota_ajuste','vw_con_adjustment_gral','recibo=\''+codigo+'\' and compania =<%=(String) session.getAttribute("_companyId")%> order by nota_ajuste');
	if(x!='') abrir_ventana1('../facturacion/notas_ajustes_config.jsp?mode=view&fp=cons_recibo_ajuste&cod='+x);
	else alert('No tiene Ajuste!');
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
              <%=fb.formStart(true)%>
							<%=fb.hidden("errCode","")%>
							<%=fb.hidden("errMsg","")%>
              <%=fb.hidden("anio",cdo.getColValue("anio"))%>
              <%=fb.hidden("codigo",cdo.getColValue("codigo"))%>
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
                      <td align="right" width="15%"><cellbytelabel>Compa&ntilde;ia</cellbytelabel></td>
                      <td width="*" colspan="9"><%=cdo.getColValue("compania")%> <%=cdo.getColValue("nombre_compania")%> </td>
                    </tr>
                    <tr class="TextRow02">
                    	<td align="right"><cellbytelabel>Recibo No</cellbytelabel>.:</td>
                      <td colspan="5" class="Text12Bold"><%=codigo%></td>
                      <td><cellbytelabel>Fecha del Pago</cellbytelabel>:</td>
                      <td colspan="3" class="Text12Bold"><%=cdo.getColValue("fecha")%></td>
                    </tr>

										<tr class="TextRow02">
                    	<td align="right"><cellbytelabel>Transacci&oacute;n</cellbytelabel>:</td>
                      <td colspan="5"><%=cdo.getColValue("anio")%>&nbsp;&nbsp;-&nbsp;&nbsp;<%=cdo.getColValue("codigo")%></td>
                      <td><cellbytelabel>Pagado por</cellbytelabel>:</td>
                      <td colspan="3"><%=cdo.getColValue("tipo_cliente_desc")%></td>
                     </tr>

										<tr class="TextRow02">
                    	<td align="right"><cellbytelabel>Paciente</cellbytelabel></td>
                      <td colspan="5" class="Text12Bold"><%=cdo.getColValue("nombre_paciente")%></td>
                      <td><cellbytelabel>C&oacute;digo Paciente</cellbytelabel>:</td>
                      <td colspan="3"><%=cdo.getColValue("f_nac")%>&nbsp;&nbsp;&nbsp;-&nbsp;&nbsp;&nbsp; <%=cdo.getColValue("codigo_paciente")%></td>
                     </tr>

                    <%=fb.hidden("cod_empresa", cdo.getColValue("cod_empresa"))%>
                    <%=fb.hidden("pac_id", cdo.getColValue("pac_id"))%>
                    <%=fb.hidden("admi_secuencia", cdo.getColValue("admi_secuencia"))%>
                    <tr class="TextRow01">
                      <td align="right"><cellbytelabel>Empresa</cellbytelabel></td>
                      <td colspan="5" class="Text12Bold"><%=cdo.getColValue("codigo_empresa")%>&nbsp;-&nbsp; <%=cdo.getColValue("nombre_empresa")%> </td>
                      <td><cellbytelabel>Concepto</cellbytelabel>:</td>
                      <td colspan="3"><%=cdo.getColValue("descripcion")%></td>
                    </tr>
                    <tr class="TextRow02">
                      <td align="right"><cellbytelabel>Caja</cellbytelabel>:</td>
                      <td colspan="4"><%=cdo.getColValue("caja")%>-<%=cdo.getColValue("nombre_caja")%></td>
                      <td><%=fb.checkbox("chkAdel","", (cdo.getColValue("adelanto").equals("S")?true:false), true, "", "", "")%>&nbsp;<cellbytelabel>Adel</cellbytelabel>.</td>
                      <td><cellbytelabel>PAGO TOTAL</cellbytelabel>:</td>
                      <td colspan="3" class="TextHeader02">B/.&nbsp;<%=CmnMgr.getFormattedDecimal("###,###,##0.##",cdo.getColValue("pago_total"))%></td>
                    </tr>

                    <tr class="TextPanel">
                      <td colspan="10"><cellbytelabel>Auditor&iacute;a</cellbytelabel></td>
                    </tr>
                    <tr class="TextRow01">
                      <td align="right"><cellbytelabel>Creaci&oacute;n</cellbytelabel>:</td>
                      <td colspan="3"><%=cdo.getColValue("usuario_creacion")%>&nbsp;&nbsp;-&nbsp;&nbsp;<%=cdo.getColValue("fecha_creacion")%></td>
                      <td align="right"><cellbytelabel>Modificaci&oacute;n</cellbytelabel>:</td>
                      <td colspan="3"><%=cdo.getColValue("usuario_modificacion")%>&nbsp;&nbsp;-&nbsp;&nbsp;<%=cdo.getColValue("fecha_modificacion")%></td>
                      <td colspan="2">&nbsp;</td>
                    </tr>

                  </table></td>
              </tr>

              <tr align="right" class="TextRow02">
                <td colspan="2">
								<!--<a href="javascript:printFact();"><img src="../images/print_bill_details.gif" border="0" height="24" width="24" title="Imprimir">--></a>&nbsp;&nbsp;&nbsp;
								<%=fb.button("btnformaPago","Forma de Pago",false,false,null,null,"onClick=\"javascript:formaPago()\"")%>
								<%=fb.button("btnAjuste","Ajuste a Recibo",false,false,null,null,"onClick=\"javascript:ajuste()\"")%>
                </td>
              </tr>
              <tr>
                <td colspan="2" onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
                    <tr class="TextPanel">
                      <td width="95%">&nbsp;<cellbytelabel>Detalle de Pagos aplicados con este recibo</cellbytelabel></td>
                      <td width="5%" align="right">[<font face="Courier New, Courier, mono">
                        <label id="plus1" style="display:none">+</label>
                        <label id="minus1">-</label>
                        </font>]&nbsp;</td>
                    </tr>
                  </table></td>
              </tr>
              <tr id="panel1">
                <td colspan="2"><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="50" scrolling="no" src="../caja/recibos_ajustes_det.jsp?codigo=<%=codigo%>&pago_total=<%=cdo.getColValue("pago_total")%>"></iframe></td>
              </tr>
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
