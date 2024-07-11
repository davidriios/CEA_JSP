<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%
//response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
response.setContentType("application/vnd.ms-excel");
response.setHeader("Content-Disposition", "attachment; filename=print_recibo_fp.xls");

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alAnul = new ArrayList();
ArrayList alFp = new ArrayList();

StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String caja = request.getParameter("caja");
String turno = request.getParameter("turno");
String compania = request.getParameter("compania");
String fechaDesde = request.getParameter("fechaini");
String fechaHasta = request.getParameter("fechafin");
String descCaja = request.getParameter("descCaja");
String formaPago = request.getParameter("formaPago");
String verFacturas = request.getParameter("verFacturas");
String fp = request.getParameter("fp");

if (appendFilter == null) appendFilter = "";
if(turno==null) turno = "";
if(fechaDesde==null) fechaDesde = "";
if(fechaHasta==null) fechaHasta = "";
if(formaPago==null) formaPago = "";
if(caja==null) caja = "";
if(verFacturas==null)verFacturas="";
if(fp==null)fp="";

sbSql.append("select 1 as ord, tp.anio, tp.codigo, tp.caja, tp.turno, tp.tipo_cliente, tp.recibo, tp.pago_total, to_char(tp.fecha,'dd/mm/yyyy') as fecha, tp.descripcion, decode(tp.tipo_cliente,'P',tp.pac_id,'E',tp.codigo_empresa) as codigoCliente, tp.nombre||decode(tp.nombre,tp.nombre_adicional,null,' / '||tp.nombre_adicional)||decode(tp.rec_status,'I',' (ANULADO)') as nombreCliente, nvl(fp.monto,0) as montoFp, fp.fp_codigo, nvl((select sum(nvl(dp.monto,0)) as montoAplicado from tbl_cja_detalle_pago dp where dp.codigo_transaccion = tp.codigo and dp.compania = tp.compania and dp.tran_anio = tp.anio),0) as montoAplicado, nvl((select sum(monto) as montoDistribuido from tbl_cja_distribuir_pago where compania = tp.compania and tran_anio = tp.anio and codigo_transaccion = tp.codigo),0) as montoDistribuido, (select descripcion from tbl_cja_cajas where codigo = tp.caja and compania = tp.compania) as descCaja, tp.usuario_creacion as usuario, (select substr(descripcion,0,10) from tbl_cja_forma_pago where codigo = fp.fp_codigo) as formaPago, ");
if(verFacturas.trim().equals("S"))sbSql.append(" nvl((select join(cursor(select fac_codigo from tbl_cja_detalle_pago dp where dp.codigo_transaccion = tp.codigo and dp.compania = tp.compania and dp.tran_anio = tp.anio group by fac_codigo having sum(nvl(monto,0)) <> 0),',') from dual),' ')");
else sbSql.append(" ' ' ");
sbSql.append(" as facturas, nvl(tp.rec_status,'A') as recStatus, case when nvl(tp.rec_status,'A') = 'I' and tp.turno = tp.turno_anulacion/* and nvl(tp.anulacion_sup,'X') <> 'S'*/ and nvl(tp.afectar_saldo,'X') <> 'S' then 'N' else 'S' end as sumarRec, case when fp.fp_codigo = 2 then nvl(to_char(fp.num_cheque),fp.no_referencia) when fp.fp_codigo in (0,1) then ' ' else fp.no_referencia end no_referencia from tbl_cja_transaccion_pago tp, tbl_cja_trans_forma_pagos fp where tp.compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(" /* and nvl(tp.rec_status,'A') <> 'I'*/ and tp.codigo = fp.tran_codigo(+) and tp.compania = fp.compania(+) and tp.anio = fp.tran_anio(+)");

if(!fechaDesde.trim().equals(""))
{
	sbSql.append(" and trunc(tp.fecha) >= to_date('");
	sbSql.append(fechaDesde);
	sbSql.append("','dd/mm/yyyy')");
}
if(!fechaHasta.trim().equals(""))
{
	sbSql.append(" and trunc(tp.fecha) <= to_date('");
	sbSql.append(fechaHasta);
	sbSql.append("','dd/mm/yyyy')");
}
if(!formaPago.trim().equals(""))
{
	sbSql.append(" and fp.fp_codigo = ");
	sbSql.append(formaPago);
}
if(!caja.trim().equals(""))
{
	sbSql.append(" and tp.caja = ");
	sbSql.append(caja);
}
if(!turno.trim().equals(""))
{
	sbSql.append(" and  tp.turno = ");
	sbSql.append(turno); 
}

sbSql.append(" union all ");
sbSql.append("select 3, 0 as anio, tp.doc_id as codigo, tp.cod_caja as caja, tp.turno, 'O' as tipo_cliente, to_char(tp.doc_id) as recibo, -tp.net_amount as pago_total, to_char(tp.doc_date,'dd/mm/yyyy') as fecha, tp.client_name as descripcion, 0 as codigocliente, tp.client_name as nombrecliente, nvl(-fp.monto,0) as montofp, fp.fp_codigo, 0 as montoaplicado, 0 as montodistribuido, (select descripcion from tbl_cja_cajas where codigo = tp.cod_caja and compania = tp.company_id) as desccaja, tp.created_by as usuario, (select substr(descripcion,0,15) from tbl_cja_forma_pago where codigo = fp.fp_codigo)||' NC' as formapago, ' ' as facturas, ' ' as recStatus, 'S', case when fp.fp_codigo = 2 then to_char(fp.num_cheque) when fp.fp_codigo in (0,1) then ' ' else fp.no_referencia end as no_referencia from tbl_fac_trx tp, tbl_fac_trx_forma_pagos fp where tp.company_id = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(" and tp.doc_type = 'NCR' and tp.tipo_factura = 'CO' and tp.doc_id = fp.doc_id(+) and tp.company_id = fp.compania(+)");
if(!fechaDesde.trim().equals(""))
{
	sbSql.append(" and trunc(tp.doc_date) >= to_date('");
	sbSql.append(fechaDesde);
	sbSql.append("','dd/mm/yyyy')");
}
if(!fechaHasta.trim().equals(""))
{
	sbSql.append(" and trunc(tp.doc_date) <= to_date('");
	sbSql.append(fechaHasta);
	sbSql.append("', 'dd/mm/yyyy')");
}
if(!formaPago.trim().equals(""))
{
	sbSql.append(" and fp.fp_codigo = ");
	sbSql.append(formaPago);
}
if(!caja.trim().equals(""))
{
	sbSql.append(" and tp.cod_caja = ");
	sbSql.append(caja);
}
if(!turno.trim().equals(""))
{
	sbSql.append(" and tp.turno = ");
	sbSql.append(turno);
}

sbSql.append(" order by 1, 4, 5, 7, 14 asc");
al = SQLMgr.getDataList(sbSql.toString());


//-----------------------------------------------------------



alFp = SQLMgr.getDataList("select sum(nvl(montoFp,0)) as montoFp, fp_codigo, (select descripcion from tbl_cja_forma_pago where codigo = fp_codigo) as formaPago from ("+sbSql.toString()+") where sumarRec = 'S' group by fp_codigo, formaPago");

sbSql = new StringBuffer(); 
sbSql.append("select 2 as ord, tp.anio, tp.codigo, tp.caja, tp.turno, tp.tipo_cliente, tp.recibo, tp.pago_total, to_char(tp.fecha_anulacion,'dd/mm/yyyy') as fecha, tp.descripcion, decode(tp.tipo_cliente,'P',tp.pac_id,'E',tp.codigo_empresa) as codigoCliente, tp.nombre||decode(tp.nombre,tp.nombre_adicional,null,' / '||tp.nombre_adicional)||decode(tp.rec_status,'I',' (ANULADO)') as nombreCliente, (select descripcion from tbl_cja_cajas where codigo = tp.caja and compania = tp.compania) as descCaja, tp.usuario_creacion as usuario, fn_cja_getFormaPago(tp.compania,tp.anio,tp.codigo) as forma_pago, nvl(tp.rec_status,'A') as recStatus, case when nvl(tp.rec_status,'A') = 'I' and tp.turno = tp.turno_anulacion/* and nvl(tp.anulacion_sup,'X') <> 'S'*/ and nvl(tp.afectar_saldo,'X') <> 'S' then 'N' else 'S' end as sumarRec, (select ctp.recibo from tbl_cja_trans_forma_pagos fpa,tbl_cja_transaccion_pago ctp where fpa.fp_codigo = '0' and ctp.compania = fpa.compania and ctp.anio = fpa.tran_anio and ctp.codigo = fpa.tran_codigo and fpa.no_referencia = tp.recibo and fpa.compania = tp.compania and ctp.rec_status <> 'I' and rownum = 1) as remp_por, tp.xtra1 as recibo_manual, tp.usuario_anulacion,'' as no_referencia from tbl_cja_transaccion_pago tp where tp.compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append("/* and nvl(tp.rec_status,'A') <> 'I'*/ /*and tp.codigo = fp.tran_codigo(+) and tp.compania = fp.compania(+) and tp.anio = fp.tran_anio(+)*/");

if(!fechaDesde.trim().equals(""))
{
	sbSql.append(" and trunc(tp.fecha) >= to_date('");
	sbSql.append(fechaDesde);
	sbSql.append("','dd/mm/yyyy')");
}
if(!fechaHasta.trim().equals(""))
{
	sbSql.append(" and trunc(tp.fecha) <= to_date('");
	sbSql.append(fechaHasta);
	sbSql.append("','dd/mm/yyyy')");
}
if(!formaPago.trim().equals(""))
{
	sbSql.append(" and exists( select null from tbl_cja_trans_forma_pagos fp where tp.codigo = fp.tran_codigo and tp.compania = fp.compania and tp.anio = fp.tran_anio and fp.fp_codigo = ");
	sbSql.append(formaPago);
	sbSql.append(")");
}
if(!caja.trim().equals(""))
{
	sbSql.append(" and tp.caja = ");
	sbSql.append(caja);
}
sbSql.append(" and (tp.turno <> tp.turno_anulacion or tp.anulacion_sup = 'S')"); 
if(!turno.trim().equals(""))
{
	sbSql.append(" and tp.turno_anulacion = ");
	sbSql.append(turno); 
}
sbSql.append(" order by 1, 4, 5, 7, 14 asc");

alAnul = SQLMgr.getDataList(sbSql.toString());


if (request.getMethod().equalsIgnoreCase("GET")){%>

<table border="1" cellpadding="0" cellspacing="0">
	<tr>
		<th width="5%">TURNO</th>
		<th width="8%">#RECIBO</th>
		<th width="18%">#CLIENTE</th>
		<th width="8%">#FECHA</th>
		<th width="9%">#TOTAL</th>
		<th width="9%">#APLICADO</th>
		<th width="9%">#DISTRIBUIDO</th>
		<th width="9%">USUARIO</th>
		<th width="17%">FORMA PAGO</th>
		<th width="8%">MONTO F.P.</th>
	</tr>
	<%
	String groupBy = "";
	String groupBy1 = "";
	Double totalCaja =0.0, totalAplicado= 0.00, totalDistribuido= 0.00,totalAplicadoCja= 0.00,totalDistribuidoCja= 0.00,total=0.00,totalFpCja=0.00,totalFp=0.00;
	int signoRec =1;
	String printFac="";
	String color = "black";
	
	for (int i=0; i<al.size(); i++) {
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		signoRec =1;
		if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("caja")+"-"+cdo.getColValue("ord"))) {
				
			if(i!=0){ %>
				
				<tr>
					<td colspan="4" align="right">Total por caja: </td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(totalCaja)%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(totalAplicadoCja)%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(totalDistribuidoCja)%></td>
					<td align="right" colspan="2">&nbsp;</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(totalFpCja)%></td>
				</tr>
			<%	
				totalCaja = 0.00;
				totalAplicadoCja= 0.00;
				totalDistribuidoCja= 0.00;
				totalFpCja  = 0.00;
			}
			%>
				<tr>
					<td colspan="10">
					CAJA: <%=cdo.getColValue("caja")%>&nbsp;-&nbsp;<%=cdo.getColValue("descCaja")%>
				    </td>
				</tr>
				
				
				<%if(cdo.getColValue("ord").trim().equals("2")){%>
					<tr>
						<td colspan="10" color="red">RECIBOS ANULADOS EN OTROS TURNOS (SUPERVISOR)</td>
					</tr>
				<%}%>
				
				
				<%if(cdo.getColValue("ord").trim().equals("3")){%>
					<tr>
						<td colspan="10">NOTAS DE CREDITOS</td>
					</tr>
				<%}
				
			}
			if(cdo.getColValue("recStatus").trim().equals("I")&&!cdo.getColValue("ord").trim().equals("1"))signoRec = -1;
				
			if(!groupBy1.trim().equals(cdo.getColValue("recibo"))){
				
				if(cdo.getColValue("recStatus").trim().equals("I")) color = "red"; 
				else color = "black";
				%>

				<tr style="color:<%=color%>">
					<td><%=cdo.getColValue("turno")%></td>
					<td><%=cdo.getColValue("recibo")%></td>
					<td><%=cdo.getColValue("nombreCliente")%></td>
					<td><%=cdo.getColValue("fecha")%></td>
				
				<%
				if(cdo.getColValue("sumarRec").trim().equals("S")){%>
					
					<td align="right"><%=(((signoRec==-1&&cdo.getColValue("sumarRec").trim().equals("S")&&!cdo.getColValue("pago_total").trim().equals("0")))?"-":"")+CmnMgr.getFormattedDecimal(cdo.getColValue("pago_total"))%></td>
					<td align="right"><%=(((signoRec==-1&&cdo.getColValue("sumarRec").trim().equals("S")&&!cdo.getColValue("montoAplicado").trim().equals("0")))?"-":"")+CmnMgr.getFormattedDecimal(cdo.getColValue("montoAplicado"))%></td>
					<td align="right"><%=(((signoRec==-1&&cdo.getColValue("sumarRec").trim().equals("S")&&!cdo.getColValue("montoDistribuido").trim().equals("0")))?"-":"")+CmnMgr.getFormattedDecimal(cdo.getColValue("montoDistribuido"))%></td>
					
				<%}else{%>
					<td align="center">-</td>
					<td align="center">-</td>
					<td align="center">-</td>
				<%}%>
				
				<td align="center"><%=cdo.getColValue("usuario")%></td>
				
				<%} else if(verFacturas.trim().equals("S")) { %>
					<td colspan="9"></td>
					
				<%}else{%>
					<td colspan="8"></td>
					
				<%} 
				
				if(cdo.getColValue("recStatus").trim().equals("I")) color = "red";
				else  color = "black";
				if(cdo.getColValue("sumarRec").trim().equals("S")) {%>
					
					<td><%=cdo.getColValue("formaPago"," ")+" - "+cdo.getColValue("no_referencia"," ")%></td>
					<td align="right"><%=(((signoRec==-1&&cdo.getColValue("sumarRec").trim().equals("S")&&!cdo.getColValue("montoFp").trim().equals("0")))?"-":"")+CmnMgr.getFormattedDecimal(cdo.getColValue("montoFp"))%></td>
					
				<%}else {%>
					<td>-</td>
					<td>-</td>
				<%}%>
				
				</tr>
				
				<%if(printFac.trim().equals("S")){ %>
					<tr>
						<td colspan="10"><%=cdo.getColValue("facturas")%></td>
					</tr>
				<%	
					printFac ="";
				}
				
			groupBy = cdo.getColValue("caja")+"-"+cdo.getColValue("ord");
			if(!groupBy1.trim().equals(cdo.getColValue("recibo"))){
			
			if(cdo.getColValue("sumarRec").trim().equals("S"))
			{
				
 					total +=signoRec*Double.parseDouble(cdo.getColValue("pago_total"));
					totalAplicadoCja+=signoRec*Double.parseDouble(cdo.getColValue("montoAplicado"));
					totalDistribuidoCja+=signoRec*Double.parseDouble(cdo.getColValue("montoDistribuido"));
		
					totalCaja +=signoRec*Double.parseDouble(cdo.getColValue("pago_total"));
					totalAplicado+=signoRec*Double.parseDouble(cdo.getColValue("montoAplicado"));
					totalDistribuido+=signoRec*Double.parseDouble(cdo.getColValue("montoDistribuido"));
			 }
			}
			groupBy1 = cdo.getColValue("recibo");
			if(cdo.getColValue("sumarRec").trim().equals("S")){
			if(cdo.getColValue("recStatus").trim().equals("I")&&!cdo.getColValue("ord").trim().equals("1"))signoRec=-1;else signoRec=1;
			totalFpCja+=signoRec*Double.parseDouble(cdo.getColValue("montoFp"));
			totalFp+=signoRec*Double.parseDouble(cdo.getColValue("montoFp"));}

	} // for i
	%>
	
	<tr>
		<td colspan="4" align="right">Total por caja: </td>
		<td align="right"><%=CmnMgr.getFormattedDecimal(totalCaja)%></td>
		<td align="right"><%=CmnMgr.getFormattedDecimal(totalAplicadoCja)%></td>
		<td align="right"><%=CmnMgr.getFormattedDecimal(totalDistribuidoCja)%></td>
		<td align="right" colspan="2">&nbsp;</td>
		<td align="right"><%=CmnMgr.getFormattedDecimal(totalFpCja)%></td>
	</tr>
	<tr>
		<td colspan="4" align="right">Total por reporte: </td>
		<td align="right"><%=CmnMgr.getFormattedDecimal(total)%></td>
		<td align="right"><%=CmnMgr.getFormattedDecimal(totalAplicado)%></td>
		<td align="right"><%=CmnMgr.getFormattedDecimal(totalDistribuido)%></td>
		<td align="right" colspan="2">&nbsp;</td>
		<td align="right"><%=CmnMgr.getFormattedDecimal(totalFp)%></td>
	</tr>
	
	
	<%if (al.size() != 0){%>
			
			<tr><td colspan="10">&nbsp;</td></tr>
			<tr>
				<td colspan="10" align="center">TOTAL RESUMIDO</td>
			</tr>
			<%
			double montoTotal =0.00;

			for (int i=0; i<alFp.size(); i++){
				CommonDataObject cdo = (CommonDataObject) alFp.get(i);
			%>
				<tr>
					<td colspan="4"><%=cdo.getColValue("formaPago")%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("montoFp"))%></td>
					<td colspan="5"></td>
				</tr>
			<%	montoTotal += Double.parseDouble(cdo.getColValue("montoFp"));
			}
			%>
			<tr>
				<td colspan="4"></td>
				<td align="right"><%=CmnMgr.getFormattedDecimal(montoTotal)%></td>
				<td colspan="5"></td>
			</tr>
	<%}%>
	
	<tr><td colspan="10">&nbsp;</td></tr>
	<tr>
		<td colspan="10" align="center">RECIBOS ANULADOS</td>
	</tr>
	
	<tr>
		<th>TURNO</th>
		<th>#RECIBO</th>
		<th colspan="3">#NOMBRE</th>
		<th>Fecha Anul.</th>
		<th colspan="2">Forma Pagado</th>
		<th>Monto Pagado</th>
		<th>U. Anul.</th>
	</tr>
	<%
	int nColsFact =0;
	String groupByCaja	 = "";
	double subTotalCja=0.00,totalAn=0.00;
	for (int a = 0; a<alAnul.size(); a++){
		CommonDataObject cdo1 = (CommonDataObject) alAnul.get(a);
		if (!groupByCaja.trim().equalsIgnoreCase(cdo1.getColValue("caja"))){
			if(a!=0){ %>
				
				<tr>
					<td colspan="5" align="right">
						Monto Anulado por caja  .   .   .   .   .   .   .   .   .   .
					</td>
					<td align="right">
						<%=" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(subTotalCja))%>
					</td>
					<td colspan="4"></td>
				</tr>
			<%
				subTotalCja =0.00;
			}
			%>
			<tr style="font-weight:bold">
				<td>Caja:</td>
				<td colspan="<%=(9+nColsFact)%>">
					<%=cdo1.getColValue("caja"," ")+" - "+cdo1.getColValue("descCaja"," ")%>
				</td>
			</tr>
		<%}%>
		
		<tr>
			<td><%=cdo1.getColValue("turno"," ")%></td>
			<td><%=cdo1.getColValue("recibo"," ")%></td>
			<td colspan="<%=(3+nColsFact)%>">
				<%=cdo1.getColValue("nombreCliente"," ")+(cdo1.getColValue("remp_por")!=null && !cdo1.getColValue("remp_por").equals("")?" - REEMPLAZADO POR: "+cdo1.getColValue("remp_por"," "):"")%>
			</td>
			<td><%=cdo1.getColValue("fecha"," ")%></td>
			<td colspan="2" align="right"><%=cdo1.getColValue("forma_pago"," ")%></td>
			<td align="right"><%="$"+CmnMgr.getFormattedDecimal("###,##0.00", cdo1.getColValue("pago_total"))%></td>
			<td><%=cdo1.getColValue("usuario_anulacion"," ")%></td>
		</tr>
		<%
		subTotalCja +=Double.parseDouble(cdo1.getColValue("pago_total"));
		totalAn += Double.parseDouble(cdo1.getColValue("pago_total"));
		
		groupByCaja = cdo1.getColValue("caja");
	
	}//for a

	if (alAnul.size() != 0){%>
		<tr style="font-weight:bold">
			<td colspan="<%=7+nColsFact%>" align="right">
				Monto Anulado por caja   .   .   .   .   .   .   .   .   .   .   
			</td>
			<td align="right" colspan="2">
				<%=" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(subTotalCja))%>
			</td>
			<td></td>
		</tr>
		
		<tr style="font-weight:bold">
			<td colspan="<%=7+nColsFact%>" align="right">
				Total Anulado   .   .   .   .   .   .   .   .   .   .   
			</td>
			<td align="right" colspan="2">
				<%=" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(totalAn))%>
			</td>
			<td></td>
		</tr>
	<%}%>
	
	<tr style="font-weight:bold">
		<td colspan="<%=7+nColsFact%>" align="right">
			Total Final   .   .   .   .   .   .   .   .   .   .   
		</td>
		<td align="right" colspan="2">
			<%=" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(total-totalAn))%>
		</td>
		<td></td>
	</tr>
	
</table>	   
	  

<%
}//GET
%>