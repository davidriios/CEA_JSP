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
if(tipo==null) tipo="";

if (request.getMethod().equalsIgnoreCase("GET"))
{

	
	//al = SQLMgr.getDataList(sbSql.toString());
	
	sbSql = new StringBuffer();
	sbSql.append(" select z.tipo,z.tipo_doc,nvl(z.codigo_cs,' ') codigo_cs, sum(nvl(z.monto,0)) monto, (nvl(z.debit,0)- nvl(z.credit,0)) ajuste, nvl(z.pagos,0) pagos_distribuidos, sum(nvl(z.descuento,0)) descuentos, sum(nvl(z.monto,0)+nvl(z.debit,0)- nvl(z.pagos,0)- nvl(z.credit,0)) saldo,z.codigo,(select nombre_paciente from vw_adm_paciente where pac_id=z.pac_id)|| ' - ' || z.pac_id || ' - ' || z.admi_secuencia || ' - No. Orden '|| nvl(getBoletasHon(z.pac_id, z.admi_secuencia,nvl(z.codigo_cs,' ')),' - ')||decode((nvl(z.debit,0)- nvl(z.credit,0)),0,'',', Ajustes: ')||nvl(getAjustes(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(",z.codigo,'");
	sbSql.append(fechaini);
	sbSql.append("','");
	sbSql.append(fechafin);
	sbSql.append("',nvl(z.codigo_cs,' '),'T'),'') nombre_referencia,nvl(getAjustes(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(",z.codigo,'");
	sbSql.append(fechaini);
	sbSql.append("','");
	sbSql.append(fechafin);
	sbSql.append("',nvl(z.codigo_cs,' '),'N' ),'') codAjustes,nvl(getAjustes(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(",z.codigo,'");
	sbSql.append(fechaini);
	sbSql.append("','");
	sbSql.append(fechafin);
	sbSql.append("',nvl(z.codigo_cs,' '),'O' ),'') codAjustesO,nvl(getPagosFactHon(z.compania,z.codigo_cs,decode(z.tipo,'M','H',z.tipo),z.codigo ,'");
	sbSql.append(fechaini);
	sbSql.append("','");
	sbSql.append(fechafin);
	sbSql.append("','TD'),0) as monto_odp,nvl(getPagosFactHon(z.compania,z.codigo_cs,decode(z.tipo,'M','H',z.tipo),z.codigo ,'");
	sbSql.append(fechaini);
	sbSql.append("','");
	sbSql.append(fechafin);
	sbSql.append("','AJ'),0) as monto_aj,nvl(getAjustesCxp(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(",z.codigo,'");
	sbSql.append(fechaini);
	sbSql.append("','");
	sbSql.append(fechafin);
	sbSql.append("',nvl(z.codigo_cs,' '),'N',decode(z.tipo,'M','H',z.tipo) ),'') as cod_aj_cxp ,nvl((select sum(nvl(h.monto_ajuste,0))-sum(nvl(h.retencion,0)) ajuste_pago from tbl_cxp_hon_det h where h.cod_medico=z.codigo_cs and h.tipo=decode(z.tipo,'M','H',z.tipo) and h.fecha >= to_date('");
  sbSql.append(fechaini);
  sbSql.append("', 'dd/mm/yyyy') and h.fecha <= to_date('");
  sbSql.append(fechafin);
  sbSql.append("', 'dd/mm/yyyy')), 0) ajuste_pago,to_char(z.fecha, 'dd/mm/yyyy') fecha_docto,z.fecha from ( select f.tipo,f.tipo_doc,getcoddetecf (f.codigo,f.tipo_doc,f.centro_servicio,f.facturar_a,f.medico,f.med_empresa,f.compania) codigo_cs, getdescdetecf (f.codigo,f.tipo_doc,f.centro_servicio,f.facturar_a,f.medico,f.med_empresa,f.compania) descripcion_cs, f.monto, nvl(getDebitHon(f.compania,f.codigo,f.tipo_doc,f.centro_servicio,f.facturar_a,f.medico,f.med_empresa,'");
	sbSql.append(fechaini);
	sbSql.append("','");
	sbSql.append(fechafin);
	sbSql.append("'),0)debit,nvl(getpagosHon(f.codigo,f.medico,f.med_empresa,f.compania,'");
	sbSql.append(fechaini);
	sbSql.append("','");
	sbSql.append(fechafin);
	sbSql.append("'), 0)pagos,getcreditHon(f.compania,f.codigo,f.tipo_doc,f.centro_servicio,f.facturar_a,f.medico,f.med_empresa,'");
	sbSql.append(fechaini);
	sbSql.append("','");
	sbSql.append(fechafin);
	sbSql.append("') credit,f.descuento, f.saldo,f.codigo,f.fecha,f.pac_id,f.admi_secuencia,f.compania from ( select decode(d.med_empresa,null,'M','E')tipo,f.pac_id, f.codigo, f.fecha, f.admi_fecha_nacimiento, f.admi_codigo_paciente, f.admi_secuencia, f.cod_empresa, f.usuario_creacion, d.tipo tipo_doc, d.med_empresa, d.medico, d.centro_servicio, sum(nvl(d.monto,0))as monto, sum (nvl (d.monto, 0)) saldo, sum (nvl (d.descuento, 0) + nvl (d.descuento2, 0)) descuento, f.facturar_a, f.estatus, f.compania, f.cuenta_i from tbl_fac_factura f, tbl_fac_detalle_factura d, tbl_cds_centro_servicio cds where f.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));
  
  sbSql.append(" and f.estatus <> 'A'  and (d.compania = f.compania and d.fac_codigo = f.codigo) and (d.tipo_cobertura <> 'CI' or d.tipo_cobertura is null) and (d.centro_servicio = cds.codigo(+)) and (d.med_empresa is not null or d.medico is not null) and f.fecha >= to_date('");
  sbSql.append(fechaini);
  sbSql.append("', 'dd/mm/yyyy') and f.fecha <= to_date('");
  sbSql.append(fechafin);
  sbSql.append("', 'dd/mm/yyyy') group by f.pac_id,f.codigo,f.fecha,f.admi_fecha_nacimiento,f.admi_codigo_paciente,f.admi_secuencia,f.cod_empresa,f.usuario_creacion,d.tipo, d.med_empresa,d.medico,d.centro_servicio,f.facturar_a,f.estatus,f.compania,f.cuenta_i having sum(nvl(d.monto,0)) <> 0 order by d.centro_servicio asc ) f union all select decode(a.cod_empresa,null,'M','E')tipo, a.tipo_doc,coalesce (a.cod_medico, to_char (a.cod_empresa), ' ') codigo_cs, coalesce (b.nombre_medico, c.nombre_empresa, ' ') descripcion_cs, 0 monto, a.debit,nvl(a.pagos,0) pagos,a.credit, 0 descuentos, (a.debit - nvl (a.pagos,0) - a.credit) saldo,a.codigo,a.fecha,a.pac_id,a.admi_secuencia,a.compania from (select distinct f.codigo, nvl (n.centro, 0) centro_servicio, nvl(sum (decode (n.lado_mov, 'D', n.monto)),0) debit, nvl(sum (decode (n.lado_mov, 'C', n.monto)),0) credit, n.empresa cod_empresa, n.medico cod_medico,n.tipo tipo_doc,nvl(getpagosHon(f.codigo, n.medico, n.empresa,n.compania,'");
	sbSql.append(fechaini);
	sbSql.append("','");
	sbSql.append(fechafin);
	sbSql.append("'), 0)pagos,f.fecha fecha,f.pac_id,f.admi_secuencia,n.compania from tbl_fac_factura f, vw_con_adjustment_gral n where f.compania = n.compania and f.compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and f.estatus <> 'A' and f.codigo = n.factura and n.monto <> 0 and (n.centro = 0) and ((n.medico not in (select distinct nvl (b.medico, 0) from tbl_fac_factura a, tbl_fac_detalle_factura b where a.compania = b.compania and a.compania =");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and a.codigo = b.fac_codigo and a.codigo =f.codigo  and a.estatus <> 'A' and nvl (b.centro_servicio, 0) = 0 and (b.medico is not null or b.med_empresa is not null))) or (n.empresa not in (select distinct nvl (b.med_empresa, 0) from tbl_fac_factura a, tbl_fac_detalle_factura b where a.compania = b.compania and a.compania =");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append("  and a.estatus <> 'A'  and a.codigo = b.fac_codigo and a.codigo =f.codigo and nvl (b.centro_servicio, 0) = 0 and (b.medico is not null or b.med_empresa is not null)))) group by f.codigo, n.centro, n.empresa, n.medico,n.tipo,n.compania,f.fecha,f.pac_id,f.admi_secuencia) a,(select codigo, primer_nombre || ' '|| segundo_nombre|| ' '|| primer_apellido|| ' '|| segundo_apellido|| ' '|| apellido_de_casada nombre_medico from tbl_adm_medico) b, (select codigo, nombre nombre_empresa from tbl_adm_empresa) c where a.cod_medico = b.codigo(+) and a.cod_empresa = c.codigo(+) and a.fecha >= to_date('");
	  sbSql.append(fechaini);
	  sbSql.append("','dd/mm/yyyy') and a.fecha <= to_date('");
	  sbSql.append(fechafin);
	  sbSql.append("','dd/mm/yyyy')) z where  z.codigo_cs ='");
	  sbSql.append(beneficiario);
	  sbSql.append("' group by z.tipo,z.tipo_doc,nvl(z.codigo_cs,' '),z.codigo_cs,z.codigo,z.pac_id,z.admi_secuencia,to_char(z.fecha, 'dd/mm/yyyy'),z.fecha,z.compania,nvl(z.debit,0)- nvl(z.credit,0),nvl(z.pagos,0) order by z.fecha,z.codigo");
	  al = SQLMgr.getDataList(sbSql.toString());

	
	
	
	cdoT = SQLMgr.getData("select nvl(sum(monto), 0) debito,nvl(sum(ajuste), 0) ajuste,0 credito, nvl(sum(pagos_distribuidos), 0) pagos_distribuidos, nvl(sum(monto_odp), 0) monto_odp,nvl(sum(ajuste_pago),0) ajuste_pago from ("+sbSql.toString()+")");

	sbSqlSI.append("select getsaldoinicialHon2(");
	sbSqlSI.append((String) session.getAttribute("_companyId"));
	sbSqlSI.append(", '");
	sbSqlSI.append(fechaini);
	sbSqlSI.append("', '");
	sbSqlSI.append(beneficiario);
	sbSqlSI.append("', '");
	sbSqlSI.append(tipo);
	sbSqlSI.append("') saldo_inicial,nvl(getAjustesCxp(");
	sbSqlSI.append((String) session.getAttribute("_companyId"));
	sbSqlSI.append(",'S/I','");
	sbSqlSI.append(fechaini);
	sbSqlSI.append("','");
	sbSqlSI.append(fechafin);
	sbSqlSI.append("','");
	sbSqlSI.append(beneficiario);
	sbSqlSI.append("','SI',decode('");
	sbSqlSI.append(tipo);
	sbSqlSI.append("','M','H','E') ),'') as cod_aj_cxp from dual");
	System.out.println("SQL SI=\n"+sbSqlSI.toString());
	cdoSI = SQLMgr.getData(sbSqlSI.toString());

		
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

function ver(tipo,codigo,monto,otros,trx)
{	
	if(monto !='0'){
	if(tipo=='F') abrir_ventana('../facturacion/print_factura.jsp?mode=view&factura='+codigo+'&compania=<%=session.getAttribute("_companyId")%>');
	else if(tipo=='R')abrir_ventana('../caja/factura_pagos.jsp?fp=CXPHON&codigo='+codigo);
	else if(tipo=='ODP'){if(otros!='0')abrir_ventana('../cxp/nota_ajuste_config.jsp?fp=CXPHON&mode=view&fg=CS&cod='+trx);abrir_ventana('../cxp/orden_pago_list.jsp?fp=CXPHON&numFactura='+codigo);}
	else if(tipo=='AJ'){
				var id ='';
				if(codigo!='')
				abrir_ventana('../facturacion/notas_ajuste_cargo_dev.jsp?mode=view&codigo='+id+'&compania=<%=session.getAttribute("_companyId")%>&nt=&fg=&pacienteId=&noAdmision=&factura='+codigo+'&tr=CS&fp=cons_ajuste&cod='+codigo);
				if(otros!='')
				abrir_ventana('../facturacion/notas_ajustes_config.jsp?mode=view&codigo='+id+'&compania=<%=session.getAttribute("_companyId")%>&nt=&fg=&pacienteId=&noAdmision=&factura='+otros+'&tr=CS&fp=cons_recibo_ajuste&cod='+otros);
			}
	}
}
function facturas(factura)
{
//abrir_ventana('../cxp/ingreso_facturas.jsp?fp=CXPHON&numFactura='+factura+'&mode=view');
abrir_ventana('../cxp/orden_pago_list.jsp?fg=CXPHON&numFactura='+factura);
}
function verSI(ajustes){abrir_ventana('../cxp/nota_ajuste_config.jsp?fp=CXPHON&mode=view&fg=CS&cod='+ajustes);}
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
        
		<tr class="TextHeader03" align="center">
          <td align="right" colspan="7"><cellbytelabel>Saldo Inicial</cellbytelabel></td>
          <td align="right" colspan="3"><%if(!cdoSI.getColValue("cod_aj_cxp").trim().equals("")){%><a href="javascript:verSI('<%=cdoSI.getColValue("cod_aj_cxp")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><font class="RedTextBold"><%=CmnMgr.getFormattedDecimal(cdoSI.getColValue("saldo_inicial"))%></font></a><%}else{%>
		  <%=CmnMgr.getFormattedDecimal(cdoSI.getColValue("saldo_inicial"))%><%}%></td>
        </tr>
		<tr class="TextHeader02" height="21">
          <!--<td align="center" width="5%">Tipo Doc.</td>-->
          <td align="center" width="30%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
          <td align="center" width="8%"><cellbytelabel>Factura</cellbytelabel></td>
          <td align="center" width="8%"><cellbytelabel>Fecha</cellbytelabel></td>
          <td align="center" width="8%"><cellbytelabel>Facturado</cellbytelabel></td>
		  <td align="center" width="8%"><cellbytelabel>Ajustado</cellbytelabel></td>
		  <td align="center" width="8%"><cellbytelabel>Cobrado</cellbytelabel></td>
		  <td align="center" width="8%"><cellbytelabel>Retenci&oacute;n/ajuste</cellbytelabel></td>
          <td align="center" width="8%"><cellbytelabel>Pagado</cellbytelabel></td>
		  <td align="center" width="8%"><cellbytelabel>Por Cobrar</cellbytelabel></td>
		  <td align="center" width="8%"><cellbytelabel>Por Pagar</cellbytelabel></td>
        </tr>
        
        <%
				double saldo = 0.00, saldo_por_pagar = 0.00, saldo_inicial = 0.00, saldo_final = 0.00;
				if(cdoSI.getColValue("saldo_inicial") != null && !cdoSI.getColValue("saldo_inicial").equals("")) saldo_inicial = Double.parseDouble(cdoSI.getColValue("saldo_inicial"));
				for (int i=0; i<al.size(); i++){
          CommonDataObject cdo = (CommonDataObject) al.get(i);

          String color = "";
          if (i%2 == 0) color = "TextRow02";
          else color = "TextRow01";
          boolean readonly = true;
					saldo = Double.parseDouble(cdo.getColValue("monto"))+Double.parseDouble(cdo.getColValue("ajuste")) - Double.parseDouble(cdo.getColValue("pagos_distribuidos"));//+ Double.parseDouble(cdo.getColValue("ajuste_pago"));
					saldo_por_pagar += Double.parseDouble(cdo.getColValue("pagos_distribuidos")) - Double.parseDouble(cdo.getColValue("monto_odp"))+Double.parseDouble(cdo.getColValue("ajuste_pago"));
					%>
					

		<%=fb.hidden("monto_aj"+i,""+cdo.getColValue("monto_aj"))%>
		<%//=fb.hidden("monto_aj"+i,""+cdo.getColValue("monto_aj"))%>
		
        <tr class="<%=color%>" align="center" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
          <!--
		  <td align="center">
          <a href="javascript:ver('<%=cdo.getColValue("codigo")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=cdo.getColValue("tipo_doc")%></a>
          </td>
		  -->
          <td align="left"><%=cdo.getColValue("nombre_referencia")%></td>
          <td align="center"><a href="javascript:facturas('<%=cdo.getColValue("codigo")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=cdo.getColValue("codigo")%></a>		  
		  
		  </td>
          <td align="center"><%=cdo.getColValue("fecha_docto")%></td>
		  
          <td align="right"><a href="javascript:ver('F','<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("monto")%>','','')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%></a></td>
		   <td align="right"><a href="javascript:ver('AJ','<%=cdo.getColValue("codAjustes")%>','<%=cdo.getColValue("ajuste")%>','<%=cdo.getColValue("codAjustesO")%>','')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ajuste"))%></a></td>
		  <td align="right"><a href="javascript:ver('R','<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("pagos_distribuidos")%>','','')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("pagos_distribuidos"))%></a></td>
		  <td align="right"><a href="javascript:ver('OAJ','<%=cdo.getColValue("codAjustes")%>','<%=cdo.getColValue("ajuste_pago")%>','<%=cdo.getColValue("codAjustesO")%>','')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ajuste_pago"))%></a></td>
          <td align="right"><a href="javascript:ver('ODP','<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("monto_odp")%>','<%=cdo.getColValue("monto_aj")%>','<%=cdo.getColValue("cod_aj_cxp")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_odp"))%></a></td>
          <td align="right">
					<font class="<%=(saldo<0?"RedTextBold":"")%>"><%=CmnMgr.getFormattedDecimal(saldo)%></font>
          </td>
          <td align="right">
					<font class="<%=(saldo<0?"RedTextBold":"")%>"><%=CmnMgr.getFormattedDecimal(saldo_por_pagar)%></font>
          </td>
        </tr>
        <%
		}
		saldo = Double.parseDouble(cdoT.getColValue("debito"))+Double.parseDouble(cdoT.getColValue("ajuste"))-Double.parseDouble(cdoT.getColValue("pagos_distribuidos"));
		saldo_por_pagar = Double.parseDouble(cdoT.getColValue("pagos_distribuidos"))-Double.parseDouble(cdoT.getColValue("monto_odp"))+Double.parseDouble(cdoT.getColValue("ajuste_pago"));
		saldo_final = saldo_inicial + saldo_por_pagar;
		%>
        <tr class="TextHeader02" align="center">
          <td align="right" colspan="3"><cellbytelabel>Total</cellbytelabel></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdoT.getColValue("debito"))%></td>
		  <td align="right"><%=CmnMgr.getFormattedDecimal(cdoT.getColValue("ajuste"))%></td>
		  <td align="right"><%=CmnMgr.getFormattedDecimal(cdoT.getColValue("pagos_distribuidos"))%></td>
		  <td align="right"><%=CmnMgr.getFormattedDecimal(cdoT.getColValue("ajuste_pago"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdoT.getColValue("monto_odp"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(saldo)%></td>
          <td align="right"><font class="<%=(saldo_final<0?"RedTextBold":"")%>"><%=CmnMgr.getFormattedDecimal(saldo_final)%></font></td>
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