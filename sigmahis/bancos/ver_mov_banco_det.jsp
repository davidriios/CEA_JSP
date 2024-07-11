<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
CommonDataObject cdoSI = new CommonDataObject();

String change = request.getParameter("change");
String key = "";
String sql = "", appendFilter = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String cod_banco = request.getParameter("cod_banco");
String cuenta_banco = request.getParameter("cuenta_banco");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String tipo_doc = request.getParameter("tipo_doc");
String consecutivo = request.getParameter("consecutivo");
String voucher = request.getParameter("voucher");
String lib_cheque = request.getParameter("lib_cheque");
if(fechaini == null) fechaini = "";
if(fechafin == null) fechafin = "";
boolean viewMode = false;
int lineNo = 0;

CommonDataObject cdoT = new CommonDataObject();

if(mode == null) mode = "add";
if(fp==null) fp="cat_ctas";
if(mode.equals("view")) viewMode = true;
if(fechaini==null) fechaini="";
if(fechafin==null) fechafin="";
if(tipo_doc==null) tipo_doc="";

if(consecutivo==null) consecutivo="";
if(voucher==null) voucher="";
if(lib_cheque==null) lib_cheque="";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(!fechaini.equals("") && !fechafin.equals("")) appendFilter += " and trunc(fecha_documento) between to_date('"+fechaini+"', 'dd/mm/yyyy') and to_date('"+fechafin+"', 'dd/mm/yyyy')";
	if(!tipo_doc.equals("")) appendFilter += " and a.tipo_doc = '"+tipo_doc+"'";
	if(!consecutivo.equals("")) appendFilter += " and a.pref_doc = '"+consecutivo+"'";
	if(!voucher.equals("")) appendFilter += " and a.numero_documento = '"+voucher+"'";
    if(!lib_cheque.equals("")) appendFilter += " and a.libro_cheque = '"+lib_cheque+"' ";
	if (!cod_banco.trim().equals("") && !cuenta_banco.trim().equals(""))
	{
		sql = "select nvl((select nvl(sum((case when lado in ('DB') then monto when lado in ('CR') then monto * (-1) end)), 0) saldo_inicial from vw_con_mov_banco where compania = " + (String) session.getAttribute("_companyId") + " and cod_banco = '"+cod_banco +"' "+(!fechaini.equals("")?" and cuenta_banco = '"+cuenta_banco+"' and trunc(fecha_documento) < to_date('"+fechaini+"','dd/mm/yyyy')":"")+") , 0)+nvl((select monto from tbl_con_movim_bancario where tipo_movimiento <= -1 and compania = " + (String) session.getAttribute("_companyId") + " and banco = "+cod_banco +" and cuenta_banco = '"+cuenta_banco+"' and estado_trans='C'), 0) saldo_inicial from dual";
		cdoSI = SQLMgr.getData(sql);

		sql = "select a.tipo_doc, a.compania, a.cod_banco, a.anio, to_char(a.fecha_documento, 'dd/mm/yyyy') fecha, a.numero_documento, a.observacion, a.descripcion descripcion_mov, a.monto, decode(a.lado, 'DB', a.monto, 0) debito, decode(a.lado, 'CR', a.monto, 0) credito, a.tipo_doc_desc, a.estado, pref_doc, a.cuenta_banco,a.tipo_movimiento ,caja from vw_con_mov_banco a where a.compania = " + (String) session.getAttribute("_companyId") + " and a.cuenta_banco = '"+cuenta_banco+"' and a.cod_banco = '"+cod_banco +"'  "+appendFilter+" order by trunc(a.fecha_documento),  lpad(a.numero_documento,30) /*a.fecha_documento, a.tipo_doc*/";
        
        
		System.out.println("SQL al....................................................................................=\n"+sql);
		al = SQLMgr.getDataList(sql);

		cdoT = SQLMgr.getData("select nvl(sum(debito), 0) debito, nvl(sum(credito), 0) credito from ("+sql+")");
	}
	else
	{
		cdoSI = null;
		cdoT = null;
	}

	if (cdoSI == null)
	{
		cdoSI = new CommonDataObject();
		cdoSI.addColValue("saldo_inicial","0");
	}
	if (cdoT == null)
	{
		cdoT = new CommonDataObject();
		cdoT.addColValue("debito","0");
		cdoT.addColValue("credito","0");
	}
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script>
function doAction(){newHeight();}

function ver(no, anio, tipo, fre_docto,cuenta,banco,fecha,tm,caja)
{
	if(tipo=='FACT' && (fre_docto == 'OC' || fre_docto == 'FC')) abrir_ventana('../inventario/reg_recepcion_con_oc.jsp?mode=view&id='+no+'&anio='+anio);
	else if(tipo=='FACT' && (fre_docto == 'FR' || fre_docto == 'FC')) abrir_ventana('../inventario/reg_recepcion_sin_oc.jsp?mode=view&id='+no+'&anio='+anio);
	else if(tipo=='DEP'||tipo=='BAN'||tipo=='DEPCAJA') abrir_ventana('../bancos/movimientobancario_config.jsp?mode=view&tipo_mov='+tm+'&consecutivo='+fre_docto+'&cuenta='+cuenta+'&banco='+banco+'&fecha='+fecha+'&anio='+anio);
	else if(tipo=='ND'||tipo=='NC') abrir_ventana('../bancos/movimientobancario_config.jsp?mode=view&tipo_mov='+tm+'&consecutivo='+fre_docto+'&cuenta='+cuenta+'&banco='+banco+'&fecha='+fecha+'&anio='+anio);
	else if(tipo=='DEV') 
	abrir_ventana('../caja/registro_deposito.jsp?mode=view&fp=deposito&consecutivo='+fre_docto+'&cuenta='+cuenta+'&banco='+banco+'&caja='+caja+'&compania=<%=(String) session.getAttribute("_companyId")%>');
	 else if(tipo=='CHK'||tipo=='TRANSF'||tipo=='ACH') abrir_ventana('../cxp/orden_pago.jsp?mode=view&num_orden_pago='+fre_docto+'&anio='+anio);
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
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
  <tr class="TextHeaderOver">
  	<td width="12%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02" height="21">
          <td align="center" width="6%">Tipo Doc.</td>
          <td align="center" width="18%">Descripcion</td>
          <td align="center" width="6%">No. Doc.</td>
		  <td align="center" width="18%">Beneficiario</td>
          <td align="center" width="19%">Observación</td>
          <td align="center" width="8%">Fecha</td>
          <td align="center" width="8%">D&eacute;bito</td>
          <td align="center" width="8%">Cr&eacute;dito</td>
          <td align="center" width="9%">Saldo</td>
        </tr>
        <tr class="TextHeader01" align="center">
          <td align="right" colspan="6">Saldo Inicial</td>
          <td align="right">&nbsp;</td>
          <td align="right">&nbsp;</td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdoSI.getColValue("saldo_inicial"))%></td>
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
					saldo += Double.parseDouble(cdo.getColValue("debito"));
					saldo -= Double.parseDouble(cdo.getColValue("credito"));
          %>
        <tr class="<%=color%>" align="center" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
          <td align="center"><authtype type='1'>
          <a href="javascript:ver('<%=cdo.getColValue("numero_documento")%>','<%=cdo.getColValue("anio")%>','<%=cdo.getColValue("tipo_doc")%>','<%=cdo.getColValue("pref_doc")%>','<%=cdo.getColValue("cuenta_banco")%>','<%=cdo.getColValue("cod_banco")%>','<%=cdo.getColValue("fecha")%>','<%=cdo.getColValue("tipo_movimiento")%>','<%=cdo.getColValue("caja")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=cdo.getColValue("tipo_doc")%></a></authtype>
          </td>
          <td align="left"><%=cdo.getColValue("tipo_doc_desc")%></td>
          <td align="center"><%=cdo.getColValue("numero_documento")%></td>
		  <td align="left"><%=cdo.getColValue("descripcion_mov")%></td>
          <td align="left"><%=cdo.getColValue("observacion")%></td>
		  <td align="center"><%=cdo.getColValue("fecha")%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("debito"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("credito"))%></td>
          <td align="right">
		  	<%if(saldo<0){%><label  class="<%=color%>" style="cursor:pointer"><label class="RedTextBold">&nbsp;&nbsp;<%}%>
				<%=CmnMgr.getFormattedDecimal(saldo)%>
			<%if(saldo<0){%>&nbsp;&nbsp;</label></label><%}%>
          </td>
        </tr>
        <%}%>
        <tr class="TextHeader02" align="center">
          <td align="right" colspan="6">Total</td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdoT.getColValue("debito"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdoT.getColValue("credito"))%></td>
          <td align="right"><font class="<%=(saldo<0?"RedTextBold":"")%>"><%=CmnMgr.getFormattedDecimal(saldo)%></font></td>
        </tr>
      </table>
    </td>
  </tr>
<%=fb.formEnd(true)%>
</table>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}%>