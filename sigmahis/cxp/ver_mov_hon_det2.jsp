<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %> 
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%> 
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
======================================================================================================================================================
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
 
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
String beneficiario = request.getParameter("beneficiario");
String tipo = request.getParameter("tipo");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String format = request.getParameter("format")==null?"0":request.getParameter("format");
if(fechaini == null) fechaini = "";
if(fechafin == null) fechafin = "";
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


	sbSql.append("select tipo, decode(tipo, 'DIST', 'COBRADO', 'AJU', 'AJUSTE', 'AJUA', 'AJUSTE FACTURACION', 'PAGOH', 'PAGOS HONORARIO', 'PAGOC', 'PAGOS CONTABILIDAD', 'FACT', 'FACTURADO', 'AUX', 'AUXILIAR', 'AJUCXP', 'AJUSTE CXP') || ' ( ' ||to_clob(nombre_paciente) || ' )' tipo_desc, compania, factura, documento, to_char(fecha, 'dd/mm/yyyy') fecha, debito, credito, distribuido, ref_type, nombre, anio,id_trx,sub_id_trx ,z.fecha as fe from vw_cxp_mov_hon_new z where compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and medico = '");
	sbSql.append(beneficiario);
	sbSql.append("'");

	sbSql.append(" and trunc(fecha) between to_date('");
	sbSql.append(fechaini);
	sbSql.append("', 'dd/mm/yyyy') and to_date('");
	sbSql.append(fechafin);
	sbSql.append("', 'dd/mm/yyyy')");
	sbSql.append(" order by fecha_creacion asc ");


		System.out.println("SQL al=\n"+sbSql.toString());
		al = SQLMgr.getDataList(sbSql.toString());

	sbSqlSI.append("select getsaldoiniHon (");
	sbSqlSI.append((String) session.getAttribute("_companyId"));
	sbSqlSI.append(", '");
	sbSqlSI.append(fechaini);
	sbSqlSI.append("', '");
	sbSqlSI.append(beneficiario);
	sbSqlSI.append("', '");
	sbSqlSI.append(tipo);
	sbSqlSI.append("') saldo_inicial from dual");
	System.out.println("SQL SI=\n"+sbSqlSI.toString());
	cdoSI = SQLMgr.getData(sbSqlSI.toString());

		cdoT = SQLMgr.getData("select nvl(sum(debito), 0) debito, nvl(sum(credito), 0) credito, nvl(sum(distribuido), 0) distribuido from ("+sbSql.toString()+")");
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function doAction(){/*if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);*/}
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
          <td align="center" width="35%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>No. Doc</cellbytelabel>.</td>
          <td align="center" width="10%"><cellbytelabel>Fecha</cellbytelabel></td> 
          <td align="center" width="10%"><cellbytelabel>D&eacute;bito</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Cr&eacute;dito</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Saldo</cellbytelabel></td>
        </tr>
        <tr class="TextHeader01" align="center">
          <td align="right" colspan="4"><cellbytelabel>Saldo Inicial</cellbytelabel></td>
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
		  <%=fb.hidden("factura"+i,cdo.getColValue("factura"))%>
		  <%=fb.hidden("anio"+i,cdo.getColValue("anio"))%>
		  <%=fb.hidden("id_trx"+i,cdo.getColValue("id_trx"))%>
		  <%=fb.hidden("sub_id_trx"+i,cdo.getColValue("sub_id_trx"))%>
        <tr class="<%=color%>" align="center" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
          <td align="center">
          <a href="javascript:ver(<%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=cdo.getColValue("tipo")%></a>
          </td>
          <!--<td align="left" width="50px"><%//=fb.textarea("tipo_desc"+i,cdo.getColValue("tipo_desc"),false,false,true,40,2,null,"width:75%","")%></td>
	  	  <td align="center"><%//=fb.textarea("doc"+i,cdo.getColValue("documento"),false,false,true,40,1,null,"width:75%","")%></td>-->
		  <td align="left"><%=cdo.getColValue("tipo_desc")%></td>
          <td align="center"><%=cdo.getColValue("documento")%></td>
          <td align="center"><%=cdo.getColValue("fecha")%></td> 
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
          <td align="right" colspan="4"><cellbytelabel>Total</cellbytelabel></td> 
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