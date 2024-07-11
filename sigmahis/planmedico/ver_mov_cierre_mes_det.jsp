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
StringBuffer sbSql = new StringBuffer();
StringBuffer sbSqlSI = new StringBuffer();
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String id_contrato = request.getParameter("id_contrato");
String tipo = request.getParameter("tipo");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String acumHonNoFacturaro = request.getParameter("acumHonNoFacturaro");
String format = request.getParameter("format")==null?"0":request.getParameter("format");
if(fechaini == null) fechaini = "";
if(fechafin == null) fechafin = "";
if(acumHonNoFacturaro == null) acumHonNoFacturaro = "";
boolean viewMode = false;
int lineNo = 0;

System.out.println(":::::::::::::::::::::::::::: f ="+format);

CommonDataObject cdoT = new CommonDataObject();

if(mode == null) mode = "add";
if(fp==null) fp="cat_ctas";
if(mode.equals("view")) viewMode = true;
if(fechaini==null) fechaini="";
if(fechafin==null) fechafin="";
if (request.getMethod().equalsIgnoreCase("GET"))
{

	if(fechaini!=null && !fechaini.equals("")){
	sbSql.append("select tipo, decode(tipo, 'FAC', 'FACTURA', 'ACH', 'ACH', 'TC', 'TARJETA CREDITO', 'AJU1', 'AJUSTE DESC. FACTURA', 'AJU2', 'AJUSTE ANULA PAGO', 'AJU3', 'AJUSTE NOTA DE CREDITO', 'M', 'PAGO MANUAL') tipo_desc, to_char(fecha, 'dd/mm/yyyy') fecha_desc, debito, credito, documento, fecha from (select id_sol_contrato id_contrato, to_char(id_fac) documento, 'FAC' tipo, fecha, monto debito, 0 credito from tbl_pm_factura where fecha between to_date ('");
		sbSql.append(fechaini);
		sbSql.append("', 'dd/mm/yyyy') and to_date ('");
		sbSql.append(fechafin);
		sbSql.append("', 'dd/mm/yyyy') union all select id_contrato, id||'-'||secuencia documento, tipo_trx, fecha_creacion, 0 debito, monto_app credito from tbl_pm_regtran_det where estado = 'A' and trunc (fecha_creacion) between to_date ('");
		sbSql.append(fechaini);
		sbSql.append("', 'dd/mm/yyyy') and to_date ('");
		sbSql.append(fechafin);
		sbSql.append("', 'dd/mm/yyyy')");
		sbSql.append(" union all ");
			sbSql.append("select a.id_solicitud, to_char(a.id) documento, 'AJU'||tipo_aju tipo, a.fecha_creacion fecha, nvl(debito, 0) debito, nvl(credito, 0) credito from tbl_pm_ajuste a, tbl_pm_ajuste_det b where a.compania = b.compania and a.id = b.id and a.estado = 'A' and b.estado = 'A' and a.tipo_ben = 1 and a.tipo_aju in (1, 2, 3) and trunc (a.fecha_creacion) between to_date ('");
			sbSql.append(fechaini);
			sbSql.append("', 'dd/mm/yyyy') and to_date ('");
			sbSql.append(fechafin);
			sbSql.append("', 'dd/mm/yyyy')");
		sbSql.append(") z where id_contrato = ");
		sbSql.append(id_contrato);
	sbSql.append(" order by fecha asc ");
	

		System.out.println("SQL al=\n"+sbSql.toString());
		al = SQLMgr.getDataList(sbSql.toString());
		
		sbSqlSI.append("select nvl(sum(debito-credito), 0) saldo_inicial from (select id_sol_contrato id_contrato, 'FAC' tipo, fecha, monto debito, 0 credito from tbl_pm_factura where fecha < to_date ('");
		sbSqlSI.append(fechaini);
		sbSqlSI.append("', 'dd/mm/yyyy') union all select b.id_contrato, b.tipo_trx, b.fecha_creacion, 0 debito, b.monto_app credito from tbl_pm_regtran a, tbl_pm_regtran_det b where a.id = b.id and (a.estado = 'A' or (a.estado = 'I' and a.fecha_anulacion is not null)) and trunc (a.fecha_creacion) < to_date ('");
		sbSqlSI.append(fechaini);
		sbSqlSI.append("', 'dd/mm/yyyy') union all ");
		sbSqlSI.append("select a.id_solicitud, 'AJU' tipo, a.fecha_creacion, nvl(debito, 0) debito, nvl(credito, 0)credito from tbl_pm_ajuste a, tbl_pm_ajuste_det b where a.compania = b.compania and a.id = b.id and a.estado = 'A' and b.estado = 'A' and a.tipo_ben = 1 and a.tipo_aju in (1, 2, 3) and trunc (a.fecha_creacion) < to_date ('");
		sbSqlSI.append(fechaini);
		sbSqlSI.append("', 'dd/mm/yyyy')");
		sbSqlSI.append(") where id_contrato = ");
		sbSqlSI.append(id_contrato);

		System.out.println("SQL SI=\n"+sbSqlSI.toString());
		cdoSI = SQLMgr.getData(sbSqlSI.toString());
		cdoT = SQLMgr.getData("select nvl(sum(debito), 0) debito, nvl(sum(credito), 0) credito from ("+sbSql.toString()+")");	
	} else {
		cdoSI.addColValue("saldo_inicial", "0");
		cdoT.addColValue("debito", "0");
		cdoT.addColValue("credito", "0");
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function doAction(){
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function ver(k)
{	

var tipo = eval('document.form.tipo'+k).value;
var id = eval('document.form.id_trx'+k).value;
var sub_id = eval('document.form.sub_id_trx'+k).value;
var anio = eval('document.form.anio'+k).value;
var factura = eval('document.form.factura'+k).value;

/*FACT    factura
PAGOH   Pagos Honorarios
PAGOC   Pagos Contabilidad
AJUA    Ajustes
AJUNA   Ajustes Nota de Ajuste

* AJU     ajuste Honorarios
DIST    distribuido
AUX     Auxiliar
*/ 
	if(tipo=='FACT') abrir_ventana('../facturacion/print_factura.jsp?mode=view&factura='+id+'&compania=<%=session.getAttribute("_companyId")%>');
	else if(tipo=='PAGOH' || tipo=='PAGOC')abrir_ventana('../cxp/orden_pago.jsp?mode=view&num_orden_pago='+id+'&anio='+anio);
	else if(tipo=='AJUA')abrir_ventana('../facturacion/notas_ajuste_cargo_dev.jsp?mode=view&codigo='+id+'&compania=<%=session.getAttribute("_companyId")%>');
	else if(tipo=='AJUNA')abrir_ventana('../facturacion/notas_ajustes_config.jsp?mode=view&codigo='+id+'&compania=<%=session.getAttribute("_companyId")%>&factura='+id);
	else if(tipo=='AUX')abrir_ventana('../contabilidad/reg_auxiliar_det.jsp?mode=view&fg=CSCXP&idTrx='+id+'&anio='+anio+'&compania=<%=session.getAttribute("_companyId")%>');
	else if(tipo=='DIST'){if(confirm('Desea consulta la distribucion del pago aplicado(ACEPTAR) O todas la consulta de los pagos de la Factura (CANCELR)')){parent.showPopWin('../caja/reg_recibo_distribucion.jsp?fg=ARC&fp=CXC&mode=view&tipoCliente=E&codigo='+id+'&compania=<%=session.getAttribute("_companyId")%>&anio='+anio+'&secuenciaPago='+sub_id+'&idx='+sub_id+'&pacId=&admision=',winWidth*.90,winHeight*.75,null,null,'');}else abrir_ventana('../caja/factura_pagos.jsp?fp=CXPHON&codigo='+factura);}
	else if(tipo=='AJU')abrir_ventana('../cxp/nota_ajuste_config.jsp?fp=CXPHON&mode=view&fg=CS&cod='+id);
	/*
	else if(tipo=='ODP'){if(otros!='0')abrir_ventana('../cxp/nota_ajuste_config.jsp?fp=CXPHON&mode=view&fg=CS&cod='+trx);abrir_ventana('../cxp/orden_pago_list.jsp?fp=CXPHON&numFactura='+factura);}
	else if(tipo=='AJ'){
				var id ='';
				if(factura!='')
				abrir_ventana('../facturacion/notas_ajuste_cargo_dev.jsp?mode=view&codigo='+id+'&compania=<%=session.getAttribute("_companyId")%>&nt=&fg=&pacienteId=&noAdmision=&factura='+factura+'&tr=CS&fp=cons_ajuste&cod='+factura);
				if(otros!='')
				abrir_ventana('../facturacion/notas_ajustes_config.jsp?mode=view&codigo='+id+'&compania=<%=session.getAttribute("_companyId")%>&nt=&fg=&pacienteId=&noAdmision=&factura='+otros+'&tr=CS&fp=cons_recibo_ajuste&cod='+otros);
			}
	}*/
}

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
<%=fb.hidden("format",format)%>
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
  <tr class="TextHeaderOver">
  	<td width="100%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02" height="21">
          <td align="center" width="5%"><cellbytelabel>Tipo Doc</cellbytelabel>.</td>
          <td align="center" width="10%"><cellbytelabel>No. Doc</cellbytelabel>.</td>
          <td align="center" width="10%"><cellbytelabel>Fecha</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>D&eacute;bito</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Cr&eacute;dito</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Saldo</cellbytelabel></td>
        </tr>
        <tr class="TextHeader01" align="center">
          <td align="right" colspan="3"><cellbytelabel>Saldo Inicial</cellbytelabel></td>
          <td align="right">&nbsp;</td>
          <td align="right">&nbsp;</td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdoSI.getColValue("saldo_inicial"))%></td>
        </tr>
        <%
				double saldoInicial = Double.parseDouble(cdoSI.getColValue("saldo_inicial") != null && !cdoSI.getColValue("saldo_inicial").equals("")?cdoSI.getColValue("saldo_inicial"):"0");
				double saldo = 0.00;
				if(cdoSI.getColValue("saldo_inicial") != null && !cdoSI.getColValue("saldo_inicial").equals("")) 
				
				if ( format.equals("0") )
					saldo = Double.parseDouble(cdoSI.getColValue("saldo_inicial"));
				for (int i=0; i<al.size(); i++){
          CommonDataObject cdo = (CommonDataObject) al.get(i);

          String color = "";
          if (i%2 == 0) color = "TextRow02";
          else color = "TextRow01";
          boolean readonly = true;
		  saldo += Double.parseDouble(cdo.getColValue("debito"));
		  saldo -= Double.parseDouble(cdo.getColValue("credito"));
		  
		  double tmpSaldo = Double.parseDouble(cdo.getColValue("debito").equals("0")?cdo.getColValue("credito"):cdo.getColValue("debito"));
		  
          %>
		  <%=fb.hidden("tipo"+i,cdo.getColValue("tipo"))%>
        <tr class="<%=color%>" align="center" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
           <td align="left"><%=cdo.getColValue("tipo_desc")%></td>
          <td align="center"><%=cdo.getColValue("documento")%></td>
          <td align="center"><%=cdo.getColValue("fecha_desc")%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("debito"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("credito"))%></td>
          <td align="right">
		  <%if(format.equals("0")){%>
			 <%if(saldo<0){%><label class="<%=color%>"><label class="RedTextBold">&nbsp;&nbsp;<%}%>
			 	<%=CmnMgr.getFormattedDecimal(saldo)%>
			 <%if(saldo<0){%>&nbsp;&nbsp;</label></label><%}%>
		  <%}else if(format.equals("1")){%>	 
		   <%if(tmpSaldo<0){%><label class="<%=color%>"><label class="RedTextBold">&nbsp;&nbsp;<%}%>
			 	<%=CmnMgr.getFormattedDecimal(tmpSaldo)%>
			 <%if(tmpSaldo<0){%>&nbsp;&nbsp;</label></label><%}%>
		  <%}%>	 
          </td>
        </tr>
        <%}%>
        <tr class="TextHeader02" align="center">
          <td align="right" colspan="3"><cellbytelabel>Total</cellbytelabel></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdoT.getColValue("debito"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdoT.getColValue("credito"))%></td>
          <td align="right">
			<%if(format.equals("0")){%>
			
			<%if(saldo<0){%><label class="TextHeader02"><label class="RedTextBold">&nbsp;&nbsp;<%}%>
			 	<%=CmnMgr.getFormattedDecimal(saldo)%>
			 <%if(saldo<0){%>&nbsp;&nbsp;</label></label><%}%>
			<%}else if(format.equals("1")){
				double saldo2 = (saldo)+(saldoInicial);
			%>
			   <%if(saldo2<0){%><label class="TextHeader02"><label class="RedTextBold">&nbsp;&nbsp;<%}%>
			 	<%=CmnMgr.getFormattedDecimal(saldo2)%>
			 <%if(saldo2<0){%>&nbsp;&nbsp;</label></label><%}%>
			   
			<%}%>
		  </td>
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