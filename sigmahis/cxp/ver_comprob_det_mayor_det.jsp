<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
/**
======================================================================================================================================================
FORMA								MENU																																				NOMBRE EN FORMA
INV950128						INVENTARIO\TRANSACCIONES\CODIGOS AXA.																				ENLACE DEL CODIGO DEL MEDICAMENTO CON LOS CODIGOS DE AXA.
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
CommonDataObject cdoSI = new CommonDataObject();

String change = request.getParameter("change");
String key = "";
String sql = "", appendFilter = "", appendOrder = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String tipo = request.getParameter("tipo");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String estado = request.getParameter("estado");
String ordensal = request.getParameter("ordensal");

if(fechaini == null) fechaini = "";
if(fechafin == null) fechafin = "";
if(fg == null) fg = "";
if(estado == null) estado = "";
if(ordensal==null) ordensal = "DESC";

boolean viewMode = false;
int lineNo = 0;

CommonDataObject cdoT = new CommonDataObject();

if(mode == null) mode = "add";
if(fp==null) fp="cat_ctas";
if(mode.equals("view")) viewMode = true;
if(fechaini==null) fechaini="";
if(fechafin==null) fechafin="";

if(!estado.trim().equals("")){appendFilter +=" and ch.estado_cheque ='"+estado+"'";}

if (ordensal.equalsIgnoreCase("DESC")) {
			appendOrder +=" order by decode(substr(aa.num_cheque,1,1), 'T',to_number( 0||substr(aa.num_cheque,2,11)), 'A',to_number( 0||substr(aa.num_cheque,2,11)), to_number(aa.num_cheque)) desc, to_date(aa.fecha_docto,'dd/mm/yyyy') desc , 5, 6, 7, 8, 9, 10, 1";
		}
		else {
			appendOrder +=" order by decode(substr(aa.num_cheque,1,1), 'T',to_number( 0||substr(aa.num_cheque,2,11)), 'A',to_number( 0||substr(aa.num_cheque,2,11)), to_number(aa.num_cheque)) asc, to_date(aa.fecha_docto,'dd/mm/yyyy') asc , 5, 6, 7, 8, 9, 10, 1";
		}





if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(!fg.trim().equals("")){
		if(!fechaini.equals("") && !fechafin.equals("") && !tipo.equals("")){
	
	sql = "select * from (select 1 orden, 'CR' lado_mov, dc.compania, dc.num_cheque, cb.cg_1_cta1 cta1, cb.cg_1_cta2 cta2, cb.cg_1_cta3 cta3, cb.cg_1_cta4 cta4, cb.cg_1_cta5 cta5, cb.cg_1_cta6 cta6, cb.descripcion, sum(dc.monto_renglon) monto_cr, 0 monto_db, ch.beneficiario, ch.tipo_pago, decode(ch.tipo_pago, 1, 'CHEQUE', 2, 'ACH', 3, 'TRANSFERENCIA') tipo_pago_desc, to_char(ch.f_emision, 'dd/mm/yyyy') fecha_docto,dc.num_factura  as no_doc ,ch.cod_banco,ch.cuenta_banco,ch.cod_compania from tbl_con_detalle_cheque dc, tbl_con_cheque ch, tbl_con_cuenta_bancaria cb, tbl_con_banco bco where dc.compania = ch.cod_compania and dc.cod_banco = ch.cod_banco and dc.cuenta_banco = ch.cuenta_banco and dc.num_cheque = ch.num_cheque and ch.cod_compania = cb.compania and ch.cod_banco = cb.cod_banco and ch.cuenta_banco = cb.cuenta_banco and bco.compania = cb.compania and bco.cod_banco = cb.cod_banco and trunc(ch.f_emision) between to_date('"+fechaini+"', 'dd/mm/yyyy') and to_date('"+fechafin+"', 'dd/mm/yyyy') and ch.cod_compania = " + (String) session.getAttribute("_companyId") + " and ch.tipo_pago = " + tipo +appendFilter+ "  group by 1, 'CR', dc.compania, dc.num_cheque, cb.cg_1_cta1, cb.cg_1_cta2, cb.cg_1_cta3, cb.cg_1_cta4, cb.cg_1_cta5, cb.cg_1_cta6, cb.descripcion,0, ch.beneficiario, ch.tipo_pago, decode(ch.tipo_pago, 1, 'CHEQUE', 2, 'ACH', 3, 'TRANSFERENCIA'), to_char(ch.f_emision, 'dd/mm/yyyy'),dc.num_factura ,ch.cod_banco,ch.cuenta_banco,ch.cod_compania /* DEBITOA*/ union select 1.5, 'DBA' lado_mov, dc.compania, dc.num_cheque, cb.cg_1_cta1 cta1, cb.cg_1_cta2 cta2, cb.cg_1_cta3 cta3, cb.cg_1_cta4 cta4, cb.cg_1_cta5 cta5, cb.cg_1_cta6 cta6, cb.descripcion, 0 monto_cr, sum(nvl(dc.monto_renglon,0)) monto_db, ch.beneficiario, ch.tipo_pago, decode(ch.tipo_pago, 1, 'CHEQUE', 2, 'ACH', 3, 'TRANSFERENCIA') tipo_pago_desc, to_char(ch.f_anulacion, 'dd/mm/yyyy') fecha_docto,dc.num_factura  as no_doc ,ch.cod_banco,ch.cuenta_banco,ch.cod_compania from  tbl_con_detalle_cheque dc, tbl_con_cheque ch, tbl_con_cuenta_bancaria cb where dc.compania = ch.cod_compania and dc.cod_banco = ch.cod_banco and dc.cuenta_banco = ch.cuenta_banco and dc.num_cheque = ch.num_cheque and ch.cod_compania = cb.compania and ch.cod_banco = cb.cod_banco and ch.cuenta_banco = cb.cuenta_banco and trunc(ch.f_anulacion) between to_date('"+fechaini+"', 'dd/mm/yyyy') and to_date('"+fechafin+"', 'dd/mm/yyyy')  and ch.cod_compania = " + (String) session.getAttribute("_companyId") + " and ch.tipo_pago = " + tipo+appendFilter + " group by 1.5, 'DBA', dc.compania, dc.num_cheque, cb.cg_1_cta1, cb.cg_1_cta2, cb.cg_1_cta3, cb.cg_1_cta4, cb.cg_1_cta5, cb.cg_1_cta6, cb.descripcion,0, ch.beneficiario, ch.tipo_pago, decode(ch.tipo_pago, 1, 'CHEQUE', 2, 'ACH', 3, 'TRANSFERENCIA'), to_char(ch.f_anulacion, 'dd/mm/yyyy'),dc.num_factura,ch.cod_banco,ch.cuenta_banco,ch.cod_compania union select 1.5, 'DBA' lado_mov, dc.compania, dc.num_cheque, cb.cg_1_cta1 cta1, cb.cg_1_cta2 cta2, cb.cg_1_cta3 cta3, cb.cg_1_cta4 cta4, cb.cg_1_cta5 cta5, cb.cg_1_cta6 cta6, cb.descripcion, 0 monto_cr, sum(dc.monto_renglon) monto_db, ch.beneficiario, ch.tipo_pago, decode(ch.tipo_pago, 1, 'CHEQUE', 2, 'ACH', 3, 'TRANSFERENCIA') tipo_pago_desc, to_char(ch.fecha_anulacion_anual, 'dd/mm/yyyy') fecha_docto,dc.num_factura  as no_doc ,ch.cod_banco,ch.cuenta_banco,ch.cod_compania from tbl_con_detalle_cheque dc, tbl_con_cheque ch, tbl_con_cuenta_bancaria cb where dc.compania = ch.cod_compania and dc.cod_banco = ch.cod_banco and dc.cuenta_banco = ch.cuenta_banco and dc.num_cheque = ch.num_cheque and ch.cod_compania = cb.compania and ch.cod_banco = cb.cod_banco and ch.cuenta_banco = cb.cuenta_banco and trunc(ch.fecha_anulacion_anual) between to_date('"+fechaini+"', 'dd/mm/yyyy') and to_date('"+fechafin+"', 'dd/mm/yyyy') and ch.cod_compania = " + (String) session.getAttribute("_companyId") + " and ch.tipo_pago = " + tipo+appendFilter+ " group by 1.5, 'DBA', dc.compania, dc.num_cheque, cb.cg_1_cta1, cb.cg_1_cta2, cb.cg_1_cta3, cb.cg_1_cta4, cb.cg_1_cta5, cb.cg_1_cta6, cb.descripcion, 0, dc.monto_renglon, ch.beneficiario, ch.tipo_pago, decode(ch.tipo_pago, 1, 'CHEQUE', 2, 'ACH', 3, 'TRANSFERENCIA'), to_char(ch.fecha_anulacion_anual, 'dd/mm/yyyy'),dc.num_factura ,ch.cod_banco,ch.cuenta_banco,ch.cod_compania /*DEBITO*/ union select 2, 'DB' lado_mov, dc.compania, dc.num_cheque, dc.cuenta1 cta1, dc.cuenta2 cta2, dc.cuenta3 cta3, dc.cuenta4 cta4, dc.cuenta5 cta5, dc.cuenta6 cta6, cg.descripcion, 0 monto_cr, sum(dc.monto_renglon) monto_db, ch.beneficiario, ch.tipo_pago, decode(ch.tipo_pago, 1, 'CHEQUE', 2, 'ACH', 3, 'TRANSFERENCIA') tipo_pago_desc, to_char(ch.f_emision, 'dd/mm/yyyy') fecha_docto,dc.num_factura  as no_doc ,ch.cod_banco,ch.cuenta_banco,ch.cod_compania from tbl_con_detalle_cheque dc, tbl_con_cheque ch, tbl_con_catalogo_gral cg where dc.compania = ch.cod_compania and dc.cod_banco = ch.cod_banco and dc.cuenta_banco = ch.cuenta_banco and dc.num_cheque = ch.num_cheque and cg.compania = dc.compania and cg.cta1 = dc.cuenta1 and cg.cta2 = dc.cuenta2 and cg.cta3 = dc.cuenta3 and cg.cta4 = dc.cuenta4 and cg.cta5 = dc.cuenta5 and cg.cta6 = dc.cuenta6 and trunc(ch.f_emision) between to_date('"+fechaini+"', 'dd/mm/yyyy') and to_date('"+fechafin+"', 'dd/mm/yyyy') and ch.cod_compania = " + (String) session.getAttribute("_companyId") + " and ch.tipo_pago = " + tipo+appendFilter + " group by 2, 'DB', dc.compania, dc.num_cheque, dc.cuenta1, dc.cuenta2, dc.cuenta3, dc.cuenta4, dc.cuenta5, dc.cuenta6, cg.descripcion, 0, dc.monto_renglon, ch.beneficiario, ch.tipo_pago, decode(ch.tipo_pago, 1, 'CHEQUE', 2, 'ACH', 3, 'TRANSFERENCIA'), to_char(ch.f_emision, 'dd/mm/yyyy'),dc.num_factura ,ch.cod_banco,ch.cuenta_banco,ch.cod_compania  UNION select 2.5, 'CRA' lado_mov, dc.compania, dc.num_cheque, dc.cuenta1 cta1, dc.cuenta2 cta2, dc.cuenta3 cta3, dc.cuenta4 cta4, dc.cuenta5 cta5, dc.cuenta6 cta6, cg.descripcion, sum(dc.monto_renglon) monto_cr, 0 monto_db, ch.beneficiario, ch.tipo_pago, decode(ch.tipo_pago, 1, 'CHEQUE', 2, 'ACH', 3, 'TRANSFERENCIA') tipo_pago_desc, to_char(ch.f_anulacion, 'dd/mm/yyyy') fecha_docto,dc.num_factura  as no_doc ,ch.cod_banco,ch.cuenta_banco,ch.cod_compania from tbl_con_detalle_cheque dc, tbl_con_cheque ch, tbl_con_catalogo_gral cg where dc.compania = ch.cod_compania and dc.cod_banco = ch.cod_banco and dc.cuenta_banco = ch.cuenta_banco and dc.num_cheque = ch.num_cheque and cg.cta1 = dc.cuenta1 and cg.cta2 = dc.cuenta2 and cg.cta3 = dc.cuenta3 and cg.cta4 = dc.cuenta4 and cg.cta5 = dc.cuenta5 and cg.cta6 = dc.cuenta6 and cg.compania = dc.compania and trunc(ch.f_anulacion) between to_date('"+fechaini+"', 'dd/mm/yyyy') and to_date('"+fechafin+"', 'dd/mm/yyyy')  and ch.cod_compania = " + (String) session.getAttribute("_companyId") + " and ch.tipo_pago = " + tipo+appendFilter + " group by 2.5, 'CRA', dc.compania, dc.num_cheque, dc.cuenta1, dc.cuenta2, dc.cuenta3, dc.cuenta4, dc.cuenta5, dc.cuenta6, cg.descripcion, dc.monto_renglon, 0, ch.beneficiario, ch.tipo_pago, decode(ch.tipo_pago, 1, 'CHEQUE', 2, 'ACH', 3, 'TRANSFERENCIA'), to_char(ch.f_anulacion, 'dd/mm/yyyy'),dc.num_factura ,ch.cod_banco,ch.cuenta_banco,ch.cod_compania   union select 2.5, 'CRA' lado_mov, dc.compania, dc.num_cheque, dc.cuenta1 cta1, dc.cuenta2 cta2, dc.cuenta3 cta3, dc.cuenta4 cta4, dc.cuenta5 cta5, dc.cuenta6 cta6, 'CUENTAS POR PAGAR OTROS' descripcion, sum(dc.monto_renglon) monto_cr, 0 monto_db, ch.beneficiario, ch.tipo_pago, decode(ch.tipo_pago, 1, 'CHEQUE', 2, 'ACH', 3, 'TRANSFERENCIA') tipo_pago_desc, to_char(ch.fecha_anulacion_anual, 'dd/mm/yyyy') fecha_docto,dc.num_factura  as no_doc ,ch.cod_banco,ch.cuenta_banco,ch.cod_compania from tbl_con_detalle_cheque dc, tbl_con_cheque ch, (select param_value cta_otros from tbl_sec_comp_param where compania in (-1," + (String) session.getAttribute("_companyId") + ") and param_name = 'CXP_CTA_OTROS') sp where dc.compania = ch.cod_compania and dc.cod_banco = ch.cod_banco and dc.cuenta_banco = ch.cuenta_banco and dc.num_cheque = ch.num_cheque and trunc(ch.fecha_anulacion_anual) between to_date('"+fechaini+"', 'dd/mm/yyyy') and to_date('"+fechafin+"', 'dd/mm/yyyy')  and ch.cod_compania = " + (String) session.getAttribute("_companyId") + " and ch.tipo_pago = " + tipo+appendFilter + " and dc.cuenta1 = substr(cta_otros, 1, instr(cta_otros,'.', 1, 1)-1) and dc.cuenta2 = substr(cta_otros, instr(cta_otros,'.', 1, 1)+1, instr(cta_otros,'.', 1, 2)-instr(cta_otros,'.', 1, 1)-1) and dc.cuenta3 = substr(cta_otros, instr(cta_otros,'.', 1, 2)+1, instr(cta_otros,'.', 1, 3)-instr(cta_otros,'.', 1, 2)-1) and dc.cuenta4 = substr(cta_otros, instr(cta_otros,'.', 1, 3)+1, instr(cta_otros,'.', 1, 4)-instr(cta_otros,'.', 1, 3)-1) and dc.cuenta5 = substr(cta_otros, instr(cta_otros,'.', 1, 4)+1, instr(cta_otros,'.', 1, 5)-instr(cta_otros,'.', 1, 4)-1) and dc.cuenta6 = substr(cta_otros, instr(cta_otros,'.', 1, 5)+1) group by  2.5, 'CRA', dc.compania, dc.num_cheque, dc.cuenta1, dc.cuenta2, dc.cuenta3, dc.cuenta4, dc.cuenta5, dc.cuenta6, 'CUENTAS POR PAGAR OTROS' , dc.monto_renglon, 0, ch.beneficiario, ch.tipo_pago, decode(ch.tipo_pago, 1, 'CHEQUE', 2, 'ACH', 3, 'TRANSFERENCIA'), to_char(ch.fecha_anulacion_anual, 'dd/mm/yyyy') ,dc.num_factura ,ch.cod_banco,ch.cuenta_banco,ch.cod_compania ) aa "+appendOrder;
		System.out.println("SQL al=\n"+sql);
		al = SQLMgr.getDataList(sql);
		
		cdoT = SQLMgr.getData("select nvl(sum(monto_db), 0) monto_db, nvl(sum(monto_cr), 0) monto_cr from ("+sql+")");
	}		
	}else{cdoT = new CommonDataObject();cdoT.addColValue("monto_db","0");cdoT.addColValue("monto_cr","0");}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function doAction(){if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);}

function ver(noDoc, banco, cuenta, compania){abrir_ventana('../cxp/cheque.jsp?mode=view&cod_banco='+banco+'&cuenta_banco='+cuenta+'&num_cheque='+noDoc);}

function printList(){abrir_ventana('../cxp/print_list_libro_cheque.jsp?fg=CONT&fDesde='+fechaIni+'&fHasta='+fechaFin+'&tipo=<%=tipo%>&estado=<%=estado%>');}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
  <tr class="TextHeaderOver">
  	<td width="12%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02" height="21">
          <td align="center" width="14%"><cellbytelabel>Tipo Doc</cellbytelabel>.</td>
          <td align="center" width="22%"><cellbytelabel>Beneficiario</cellbytelabel></td>
          <td align="center" width="8%"><cellbytelabel>No. Fact.</cellbytelabel>.</td>
          <td align="center" width="8%"><cellbytelabel>Fecha</cellbytelabel></td>
          <td align="center" width="32%"><cellbytelabel>Cuenta</cellbytelabel></td>
          <td align="center" width="08%"><cellbytelabel>D&eacute;bito</cellbytelabel></td>
          <td align="center" width="08%"><cellbytelabel>Cr&eacute;dito</cellbytelabel></td>
        </tr>
        <%
				double saldo = 0.00;
				if(cdoSI.getColValue("saldo_inicial") != null && !cdoSI.getColValue("saldo_inicial").equals("")) saldo = Double.parseDouble(cdoSI.getColValue("saldo_inicial"));
				for (int i=0; i<al.size(); i++){
          CommonDataObject cdo = (CommonDataObject) al.get(i);

          String color = "";
          if (i%2 == 0) color = "TextRow02";
          else color = "TextRow01";
          boolean readonly = true;
					saldo += Double.parseDouble(cdo.getColValue("monto_db"));
					saldo -= Double.parseDouble(cdo.getColValue("monto_cr"));
          %>
        <tr class="<%=color%>" align="center" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
          <td align="center">
          <a href="javascript:ver('<%=cdo.getColValue("num_cheque")%>','<%=cdo.getColValue("cod_banco")%>','<%=cdo.getColValue("cuenta_banco")%>','<%=cdo.getColValue("cod_compania")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=cdo.getColValue("tipo_pago_desc")+" [ "+cdo.getColValue("num_cheque")+" ]"%></a>
          </td>
          <td align="left"><%=cdo.getColValue("beneficiario")%></td>
          <td align="center"><%=cdo.getColValue("no_doc")%></td>
          <td align="center"><%=cdo.getColValue("fecha_docto")%></td>
          <td align="left"><%=cdo.getColValue("cta1")+"."+cdo.getColValue("cta2")+"."+cdo.getColValue("cta3")+"."+cdo.getColValue("cta4")+"."+cdo.getColValue("cta5")+"."+cdo.getColValue("cta6")+" - "+cdo.getColValue("descripcion")%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_db"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_cr"))%></td>
        </tr>
        <%}%>
        <tr class="TextHeader02" align="center">
          <td align="right" colspan="5"><cellbytelabel>Total</cellbytelabel></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdoT.getColValue("monto_db"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdoT.getColValue("monto_cr"))%></td>
        </tr>
      </table>
    </td>
  </tr>
</table>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}%>