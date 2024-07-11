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
String sql = "", appendFilter = "";
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String cod_proveedor = request.getParameter("cod_proveedor");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin"); 
String noDoc = request.getParameter("noDoc"); 
String tipoFac = request.getParameter("tipoFac"); 
String doc_morosidad = request.getParameter("doc_morosidad");
if(fechaini == null) fechaini = "";
if(fechafin == null) fechafin = ""; 
if(noDoc == null) noDoc = ""; 
if(tipoFac == null) tipoFac = ""; 
boolean viewMode = false;
int lineNo = 0;
String compania = (String)session.getAttribute("_companyId");
CommonDataObject cdoT = new CommonDataObject();

if(mode == null) mode = "add";
if(fp==null) fp="cat_ctas";
if(mode.equals("view")) viewMode = true;
if(fechaini==null) fechaini="";
if(fechafin==null) fechafin="";
String vista ="vw_cxp_mov_proveedor";
if(fg.trim().equals("MG"))vista ="vw_cxp_mov_proveedor_mg";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(!fechaini.equals("") && !fechafin.equals("")) appendFilter = " and trunc(fecha_documento) between to_date('"+fechaini+"', 'dd/mm/yyyy') and to_date('"+fechafin+"', 'dd/mm/yyyy')";
	if(!noDoc.equals("")) appendFilter += " and a.numero_factura ='"+noDoc+"'";
	sbSql.append("select nvl(sum(nvl (debito, 0) - nvl(credito, 0)),0) saldo_inicial from ");
	sbSql.append(vista);
	sbSql.append(" where compania = ");
	sbSql.append(compania);
	sbSql.append(" and cod_proveedor = '");
	sbSql.append(cod_proveedor);
	sbSql.append("' and nvl(tipo_doc,'OT') !='FACTP'");
	if(!fechaini.equals("")){
	sbSql.append(" and trunc(fecha_documento) < to_date('");
	sbSql.append(fechaini);
	sbSql.append("','dd/mm/yyyy')");}
	if(!tipoFac.equals("")){
		sbSql.append(" and fg != '");
		sbSql.append(tipoFac);
		sbSql.append("'");
	}
	
	if(doc_morosidad==null) doc_morosidad="";
	if(!doc_morosidad.equals("")){
		sbSql.append(" and (case when fg in ('NA', 'PNA') and tipo_doc != 'AUX' then 'DSF' else 'DCF' end) = '");
		sbSql.append(doc_morosidad);
		sbSql.append("'");
		sbSql.append(" and (case when fg in ('NA', 'PNA') and tipo_doc != 'AUX' then 'DSF' else 'DCF' end) = '");
		sbSql.append(doc_morosidad);
		sbSql.append("'");
	}
	cdoSI = SQLMgr.getData(sbSql.toString());
	sbSql = new StringBuffer();
	sbSql.append("select a.tipo_doc, (case when fg in ('NA', 'PNA') and a.tipo_doc != 'AUX' then 'SF' else 'CF' end) con_sin_fact, a.compania, a.cod_proveedor, a.anio, to_char(a.fecha_documento, 'dd/mm/yyyy') fecha, a.numero_documento, a.numero_factura, a.monto, a.credito, a.debito, decode(a.tipo_doc, 'FACT', 'FACTURA','FACTAN', 'FACTURA ANULADA', 'ND', 'NOTA DE DEBITO','NDAN', 'NOTA DE DEBITO ANULADA', 'NC', 'NOTA DE CREDITO','NCAN', 'NOTA DE CREDITO ANULADA', 'PAGO', 'PAGO','PAGOAN', 'PAGO ANULADO','DEV', 'DEVOLUCION','DEVAN', 'DEVOLUCION ANULADA','AUX','DETALLE COMP. AUXILIAR','REC','RECIBOS DE CAJA','RECAN','RECIBOS DE CAJA ANULADO','FACTP','FACTURAS PACIENTES','PAGONA','PAGOS NO APLICADOS','PAGONAAN','PAGOS NO APLICADOS ANULADOS') tipo_doc_desc, a.fre_docto, a.estado, a.tipo_docto, a.extra, nvl(a.fg,'O') fg, a.fecha_documento f_doc, decode(a.fg,'CONT','FACTURAS CONTADO','CRE','FACTURAS CREDITOS','FACTP','FACTURAS PACIENTES (CXC)','OTROS') fgDesc,a.nombre_paciente,doc_ref from ");
	sbSql.append(vista);
	sbSql.append(" a, tbl_com_proveedor p where a.compania = ");
	sbSql.append(compania);
	sbSql.append(" and a.cod_proveedor = '");
	sbSql.append(cod_proveedor);
	sbSql.append("' ");
	sbSql.append(appendFilter);
	if(!tipoFac.equals("")){
		sbSql.append(" and fg != '");
		sbSql.append(tipoFac);
		sbSql.append("'");
	}
	if(!doc_morosidad.equals("")){
		sbSql.append(" and (case when fg in ('NA', 'PNA') and tipo_doc != 'AUX' then 'DSF' else 'DCF' end) = '");
		sbSql.append(doc_morosidad);
		sbSql.append("'");
		sbSql.append(" and (case when fg in ('NA', 'PNA') and tipo_doc != 'AUX' then 'DSF' else 'DCF' end) = '");
		sbSql.append(doc_morosidad);
		sbSql.append("'");
	}
	sbSql.append(" and a.cod_proveedor  = to_char(p.cod_provedor)  and a.compania = p.compania");
	sql=sbSql.toString();
	sbSql.append(" order by nvl(a.fg,'D'), 2, a.fecha_documento");

	al = SQLMgr.getDataList(sbSql.toString());

	appendFilter = " and nvl(tipo_doc,'OT') !='FACTP' ";
	sql +=appendFilter;
	cdoT = SQLMgr.getData("select nvl(sum(debito), 0) debito, nvl(sum(credito), 0) credito from ("+sql+")");
		
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

function ver(no, anio, tipo, fre_docto, tipo_docto)
{	
	if((tipo=='FACT'||tipo=='FACTAN') && (fre_docto == 'OC' || fre_docto == 'FC')) abrir_ventana('../inventario/reg_recepcion_con_oc.jsp?mode=view&id='+no+'&anio='+anio);
	else if((tipo=='FACT' ||tipo=='FACTAN') && (fre_docto == 'FR' || fre_docto == 'FC') && tipo_docto == 'I') abrir_ventana('../inventario/reg_recepcion_sin_oc.jsp?mode=view&id='+no+'&anio='+anio);
	else if((tipo=='FACT' ||tipo=='FACTAN')&& fre_docto == 'FR' && tipo_docto == 'S') abrir_ventana('../cxp/fact_prov.jsp?mode=view&numero_documento='+no+'&anio='+anio);	
	else if((tipo=='FACT'||tipo=='FACTAN') && fre_docto == 'FG') abrir_ventana('../inventario/reg_recepcion_fact_prov.jsp?mode=view&id='+no+'&anio='+anio);	
	else if(tipo=='ND' || tipo=='NC'||tipo=='NDAN' || tipo=='NCAN') abrir_ventana('../cxp/nota_ajuste_config.jsp?mode=?mode=view&code='+no+'&anio='+anio);
	else if(tipo=='PAGO'||tipo=='PAGOAN' )   abrir_ventana('../cxp/cheque.jsp?mode=view&num_orden_pago='+no+'&anio='+anio+'&fg=CSOP');
	else if(tipo=='PAGONA'||tipo=='PAGONAAN') abrir_ventana('../cxp/cheque.jsp?mode=view&num_orden_pago='+no+'&anio='+anio+'&fg=CSOP');
	else if(tipo=='AUX')abrir_ventana('../contabilidad/reg_auxiliar_det.jsp?mode=view&fg=CSCXP&idTrx='+no+'&anio='+anio);
	else if(tipo=='REC'||tipo=='RECAN')abrir_ventana1('../caja/consulta_recibos.jsp?mode=view&codigo='+no+'&compania=<%=compania%>&anio='+anio);
	else if(tipo=='FACTP')abrir_ventana('../facturacion/print_factura.jsp?mode=view&fg=CSCXP&factura='+no+'&compania=<%=compania%>');
	else if(tipo=='DEV'||tipo=='DEVAN')abrir_ventana('../inventario/reg_dev_proveedor.jsp?mode=view&fg=CSCXP&id='+no+'&compania=<%=compania%>&anio='+anio);
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
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
  <tr class="TextHeaderOver">
  	<td width="12%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02" height="21">
          <td align="center" width="10%"><cellbytelabel>Tipo Doc</cellbytelabel>.</td>
          <td align="center" width="12%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
          <td align="center" width="15%"><cellbytelabel>No. Doc</cellbytelabel>.</td>
          <td align="center" width="15%"><cellbytelabel>Factura/Doc.</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Fecha</cellbytelabel></td>
          <td align="center" width="14%"><cellbytelabel>D&eacute;bito</cellbytelabel></td>
          <td align="center" width="14%"><cellbytelabel>Cr&eacute;dito</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Saldo</cellbytelabel></td>
        </tr>
        <tr class="TextHeader01" align="center">
          <td align="right" colspan="5"><cellbytelabel>Saldo Inicial</cellbytelabel></td>
          <td align="right">&nbsp;</td>
          <td align="right">&nbsp;</td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdoSI.getColValue("saldo_inicial"))%></td>
        </tr>
        <%
				double saldo = 0.00,totDbFg=0.00,totCrFg=0.00,saldoFg=0.00,totDbCre=0.00,totCrCre=0.00,saldoCre=0.00;
				String groupBy="",groupByDesc="";
				boolean printTotal =false, showRow = true;
				if(cdoSI.getColValue("saldo_inicial") != null && !cdoSI.getColValue("saldo_inicial").equals("")) saldo = Double.parseDouble(cdoSI.getColValue("saldo_inicial"));
				for (int i=0; i<al.size(); i++){
          CommonDataObject cdo = (CommonDataObject) al.get(i);

          String color = "";
          if (i%2 == 0) color = "TextRow02";
          else color = "TextRow01";
          boolean readonly = true;
					if(cdo.getColValue("tipo_doc").equals("FACT") && cdo.getColValue("estado").equals("A")){
						cdo.addColValue("tipo_doc_desc", cdo.getColValue("tipo_doc_desc") + " - "+CmnMgr.getFormattedDecimal(cdo.getColValue("debito")));
						cdo.addColValue("debito", "0");
					}
					
					
         if(cdo.getColValue("fg").trim().equals("FACTP")&&i!=0){printTotal=true;}
		 	
					
				if(i==0 && cdo.getColValue("con_sin_fact").equals("CF")){
				%>
				<tr class="TextHeader02" align="center">
						<td colspan="8"><cellbytelabel>DOCUMENTOS CON FACTURAS</cellbytelabel></td>
				</tr>
				<%}
		if(!groupBy.trim().equals(cdo.getColValue("fg"))){
		if(i!=0){
			%>
		 <tr class="TextHeader02" align="center">
          <td align="right" colspan="5"><cellbytelabel>Total: <%=groupByDesc%></cellbytelabel></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totDbFg)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totCrFg)%></td>
          <td align="right"><%if(saldo <0){%><label class="TextHeader02"><label class="RedTextBold">&nbsp;&nbsp;
		  		<%=CmnMgr.getFormattedDecimal(saldo)%>  
		   	 &nbsp;&nbsp;</label></label><%}else{%>
			 
			 <%=CmnMgr.getFormattedDecimal(saldo)%>  
			 <%}%>
		  </td>
        </tr>
		<%if(printTotal){%>
		
		<tr class="TextHeader02" align="center">
          <td align="right" colspan="5"><cellbytelabel>Total SIN (FACTURAS CONTADO, FACTURAS DE CXC)</cellbytelabel></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totDbCre)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totCrCre)%></td>
          <td align="right"><%if(saldoCre <0){%><label class="TextHeader02"><label class="RedTextBold">&nbsp;&nbsp;
		  		<%=CmnMgr.getFormattedDecimal(saldoCre)%>  
		   	 &nbsp;&nbsp;</label></label><%}else{%>
			 
			 <%=CmnMgr.getFormattedDecimal(saldoCre)%>  
			 <%}%>
		  </td>
        </tr>	<!---->
		<tr class="TextHeader02" align="center">
          <td align="right" colspan="5"><cellbytelabel>TOTAL CXP</cellbytelabel></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdoT.getColValue("debito"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdoT.getColValue("credito"))%></td>
          <td align="right">
		   <%if(saldo <0){%><label class="TextHeader02"><label class="RedTextBold">&nbsp;&nbsp;
		  		<%=CmnMgr.getFormattedDecimal(saldo)%>  
		   	 &nbsp;&nbsp;</label></label><%}else{%>
			 
			 <%=CmnMgr.getFormattedDecimal(saldo)%>  &nbsp;&nbsp;
			 <%}%>
		  </td>
        </tr>
		
		<%totDbCre=0.00;totDbCre=0.00;saldoCre=0.00;//saldo=0.00;
		
		}saldoFg=0.00;totCrFg=0.00;totDbFg=0.00;
		}
				if(cdo.getColValue("con_sin_fact").equals("SF") && showRow){
				%>
				<tr class="TextHeader02" align="center">
						<td colspan="8"><cellbytelabel>DOCUMENTOS SIN FACTURAS</cellbytelabel></td>
				</tr>

				<%
				showRow=false;
				}
		%>
		<tr class="TextHeader">
          <td colspan="8"><cellbytelabel><%=cdo.getColValue("fgDesc")%></cellbytelabel></td>
        </tr>
		<%}
			totDbFg += Double.parseDouble(cdo.getColValue("debito"));
			totCrFg += Double.parseDouble(cdo.getColValue("credito"));	
			
			saldoFg += Double.parseDouble(cdo.getColValue("debito"));
			saldoFg -= Double.parseDouble(cdo.getColValue("credito"));
			saldo += Double.parseDouble(cdo.getColValue("debito"));
			saldo -= Double.parseDouble(cdo.getColValue("credito"));
			
			if(!cdo.getColValue("fg").trim().equals("CONT")&&!cdo.getColValue("fg").trim().equals("FACTP"))
			{
				totDbCre += Double.parseDouble(cdo.getColValue("debito"));
				totCrCre += Double.parseDouble(cdo.getColValue("credito"));	
				
				saldoCre += Double.parseDouble(cdo.getColValue("debito"));
				saldoCre -= Double.parseDouble(cdo.getColValue("credito"));
			}
		
		
		%>
        <tr class="<%=color%>" align="center" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
          <td align="center">
          <a href="javascript:ver('<%=((cdo.getColValue("tipo_doc").equals("PAGO")||cdo.getColValue("tipo_doc").equals("PAGONA"))?cdo.getColValue("extra"):cdo.getColValue("numero_documento"))%>','<%=cdo.getColValue("anio")%>','<%=cdo.getColValue("tipo_doc")%>','<%=cdo.getColValue("fre_docto")%>','<%=cdo.getColValue("tipo_docto")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=cdo.getColValue("tipo_doc")%></a>
          </td>
          <td align="left"><%=cdo.getColValue("tipo_doc_desc")%></td>
		  <%if(!cdo.getColValue("fg").trim().equals("FACTP")){%>
          <td align="center"><%=(!cdo.getColValue("doc_ref").equals(""))?"["+cdo.getColValue("doc_ref")+"] -":""%><%=cdo.getColValue("numero_documento")%></td>
          <td align="center"><%=cdo.getColValue("numero_factura")%></td>
		  <%}else{%>
		    <td align="center" colspan="2"><%=cdo.getColValue("nombre_paciente")%>-<%=cdo.getColValue("numero_documento")%></td>		  
		  <%}%>
          <td align="center"><%=cdo.getColValue("fecha")%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal((cdo.getColValue("tipo_doc").equals("FACT") && cdo.getColValue("estado").equals("A")?"0":cdo.getColValue("debito")))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("credito"))%></td>
          <td align="right">
		   <%if(saldo <0){%><label class="<%=color%>"><label class="RedTextBold">&nbsp;&nbsp;
		  		<%=CmnMgr.getFormattedDecimal(saldo)%>  
		   	 &nbsp;&nbsp;</label></label><%}else{%>
			 
			 <%=CmnMgr.getFormattedDecimal(saldo)%>  
			 <%}%>
		  
					
          </td>
        </tr>
        <% groupBy = cdo.getColValue("fg");groupByDesc=cdo.getColValue("fgDesc");}%>
         <tr class="TextHeader02" align="center">
          <td align="right" colspan="5"><cellbytelabel>Total: <%=groupByDesc%></cellbytelabel></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totDbFg)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totCrFg)%></td>
          <td align="right">
		  
		  <%if(saldo <0){%><label class="TextHeader02"><label class="RedTextBold">&nbsp;&nbsp;
		  		<%=CmnMgr.getFormattedDecimal(saldo)%>  
		   	 &nbsp;&nbsp;</label></label><%}else{%>
			 
			 <%=CmnMgr.getFormattedDecimal(saldo)%>  
			 <%}%>
			 
		  
		  </td>
        </tr>
		<%if(!printTotal){%>
		<tr class="" align="center">
		<td colspan="8">&nbsp;</td>
		</tr>
		<tr class="TextHeader02" align="center">
          <td align="right" colspan="5"><cellbytelabel>Total SIN (FACTURAS CONTADO, FACTURAS DE CXC)</cellbytelabel></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totDbCre)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totCrCre)%></td>
          <td align="right"><%if(saldo <0){%><label class="TextHeader02"><label class="RedTextBold">&nbsp;&nbsp;
		  		<%=CmnMgr.getFormattedDecimal(saldo)%>  
		   	 &nbsp;&nbsp;</label></label><%}else{%>
			 
			 <%=CmnMgr.getFormattedDecimal(saldo)%>  
			 <%}%>
		  </td>
        </tr>	<!---->
		<tr class="TextHeader02" align="center">
          <td align="right" colspan="5"><cellbytelabel>TOTAL CXP </cellbytelabel></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdoT.getColValue("debito"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdoT.getColValue("credito"))%></td>
          <td align="right"><font class="<%=(saldo<0?"RedTextBold":"")%>"><%=CmnMgr.getFormattedDecimal(saldo)%></font>&nbsp;&nbsp;&nbsp;</td>
        </tr>
		<%}%>	
		<tr class="TextHeader02" align="center">
          <td align="right" colspan="5"><cellbytelabel>SALDO NETO POR PROVEEDOR:</cellbytelabel></td>
          <td align="right">&nbsp;</td>
          <td align="right">&nbsp;</td>
          <td align="right"><%if(saldo <0){%><label class="TextHeader02"><label class="RedTextBold">&nbsp;&nbsp;
		  		<%=CmnMgr.getFormattedDecimal(saldo)%>  
		   	 &nbsp;&nbsp;</label></label><%}else{%>
			 
			 <%=CmnMgr.getFormattedDecimal(saldo)%>  
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