<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList lista = new ArrayList();

String mode = request.getParameter("mode");
String codigo = request.getParameter("codigo");
String pago_total = request.getParameter("pago_total");
String key = "";
String sql = "";
int lastLineNo = 0;
if(pago_total == null || pago_total.equals("")) pago_total = "0";
if (request.getParameter("lastLineNo") != null && !request.getParameter("lastLineNo").equals("")) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
else lastLineNo = 0;

if (request.getMethod().equalsIgnoreCase("GET"))
{
		sql = "select 'PAGO' tipo_docto, b.fac_codigo, b.admi_secuencia, to_char(b.cod_rem) cod_rem, b.doc_a_nombre nombre_paciente, to_char(b.tipo_transaccion) tipo_transaccion, decode(b.tipo_transaccion, 1, 'CANCELACION', 2, 'ABONO', 3, 'COPAGO', 4, 'DEPOSITOS') tipo_transaccion_desc, sum(b.monto)monto, b.secuencia_pago, b.pago_por, decode(b.pago_por, 'F', 'Factura', 'C', 'Pre-Factura') pago_por_desc, codigo_transaccion, tran_anio, secuencia_pago, to_char(b.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fecha,b.usuario_creacion as usuario from tbl_cja_transaccion_pago a, tbl_cja_detalle_pago b, tbl_cja_recibos f where a.codigo = b.codigo_transaccion and a.compania = b.compania and a.anio = b.tran_anio and a.compania = f.compania and a.codigo = f.ctp_codigo and a.anio = f.ctp_anio and f.compania = "+(String) session.getAttribute("_companyId")+" and f.codigo = '"+codigo+"' and a.rec_status <> 'I' group by 'PAGO', b.doc_a_nombre,b.fac_codigo, b.admi_secuencia, to_char(b.cod_rem), to_char(b.tipo_transaccion), decode(b.tipo_transaccion, 1, 'CANCELACION', 2, 'ABONO', 3, 'COPAGO', 4, 'DEPOSITOS'),b.secuencia_pago, b.pago_por, decode(b.pago_por, 'F', 'Factura', 'C', 'Pre-Factura'), codigo_transaccion, tran_anio, secuencia_pago ,a.tipo_cliente,b.compania ,to_char(b.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am'),b.usuario_creacion  union select 'AJUSTE' tipo_docto, b.factura, c.admi_secuencia, ' ' referencia, p.primer_apellido|| ' '|| p.segundo_apellido|| ' '|| p.apellido_de_casada|| ' '|| p.primer_nombre|| ' '|| p.segundo_nombre nombre_paciente, c.facturar_a tipo_transaccion, decode(c.facturar_a, 'P', 'Paciente', 'E', 'Empresa', 'O', 'Otros') tipo_transaccion_desc, b.monto, b.nota_ajuste codigo, ' ', 'AJUSTE CR. A RECIBO', 0 codigo_transaccion, 0 tran_anio, 0 secuencia_pago,to_char(b.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fecha,b.usuario_creacion  from vw_con_adjustment_gral b, tbl_fac_factura c, tbl_adm_paciente p where b.lado_mov = 'C' and b.tipo_doc = 'R' and b.recibo is not null and b.factura is not null and b.recibo = '"+codigo+"' and b.compania = "+(String) session.getAttribute("_companyId")+" and b.factura = c.codigo and b.compania = c.compania and c.pac_id = p.pac_id and exists (select n.nota_ajuste || n.compania from vw_con_adjustment_gral n where n.recibo = '"+codigo+"' and n.nota_ajuste = b.nota_ajuste and n.compania = b.compania and n.lado_mov = 'D' and n.tipo_doc = 'R' and n.compania = "+(String) session.getAttribute("_companyId")+" and n.factura is null and n.centro is null and n.empresa is null and n.medico is null) order by  15 desc ";
		al = SQLMgr.getDataList(sql);
		
		
		sql = "select nvl(sum(decode(z.lado_mov,'D',-z.monto)),0) ajusteDb ,nvl(sum(decode(z.lado_mov,'C',z.monto)),0)ajusteCr  from vw_con_adjustment_gral z, tbl_fac_tipo_ajuste y where z.recibo = '"+codigo+"' and z.compania = "+(String) session.getAttribute("_companyId")+" and z.factura is null and z.tipo_doc = 'R' and z.tipo_ajuste = y.codigo and z.compania = y.compania and y.group_type in ('H','D') and z.tipo_ajuste not in(select column_value  from table( select split((select get_sec_comp_param(z.compania,'CJA_TP_AJ_REC') from dual),',') from dual  )) ";
		
		  cdo = SQLMgr.getData(sql);
		  if(cdo == null ){cdo = new CommonDataObject();cdo.addColValue("ajusteCr","0");}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Detalle de Factura con Pagos - '+document.title;

function doSubmit()
{
 document.formDetalle.submit();
}
function doAction()
{
 newHeight();
}
function verDist(i)
{
	var codigo_transaccion = eval('document.formDetalle.codigo_transaccion'+i).value;
	var tran_anio = eval('document.formDetalle.tran_anio'+i).value;
	var secuencia_pago = eval('document.formDetalle.secuencia_pago'+i).value;

	abrir_ventana1('../caja/ver_dist_pagos.jsp?codigo='+codigo_transaccion+'&anio='+tran_anio+'&secuencia_pago='+secuencia_pago);
}

function printFact(i)
{
	var pac_id = parent.document.formFactura.pac_id.value;
	var admi_secuencia = eval('document.formDetalle.admision'+i).value;
	var codigo = eval('document.formDetalle.facCodigo'+i).value;
	abrir_ventana1('../facturacion/print_estado_cargo_det.jsp?pacId='+pac_id+'&noSecuencia='+admi_secuencia+'&factId='+codigo);
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder"><table align="center" width="100%" cellpadding="0" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <%fb = new FormBean("formDetalle",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
        <%=fb.formStart(true)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("lastLineNo",""+lastLineNo)%>
				<%=fb.hidden("keySize",""+HashDet.size())%>
        <tr class="TextHeader" align="center">
          <td width="8%"><cellbytelabel>Pago por</cellbytelabel></td>
          <td width="10%"><cellbytelabel>Factura</cellbytelabel></td>
          <td width="6%"><cellbytelabel>Admi</cellbytelabel>.#</td>		  
          <td width="22%"><cellbytelabel>Fecha/usuario</cellbytelabel>.</td>
          <td width="25%"><cellbytelabel>Nombre del Paciente</cellbytelabel></td>
          <td width="11%"><cellbytelabel>Tipo de Pago</cellbytelabel></td>
          <td width="7%"><cellbytelabel>Monto aplicado</cellbytelabel></td>
          <td width="7%"><cellbytelabel>Sec. de pago</cellbytelabel></td>
          <td width="4%">&nbsp;</td>
        </tr>
        <%
				double pago = 0.00, ajuste = 0.00, total_pago = 0.00,ajusteCr=0.00,ajusteDb=0.00;
				total_pago = Double.parseDouble(pago_total);
				ajusteCr = Double.parseDouble(cdo.getColValue("ajusteCr"));
				ajusteDb = Double.parseDouble(cdo.getColValue("ajusteDb"));
				for (int i = 0; i < al.size(); i++){
					CommonDataObject cdo2 = (CommonDataObject) al.get(i);
					if(cdo2.getColValue("tipo_docto").equals("PAGO")) pago += Double.parseDouble(cdo2.getColValue("monto"));
					if(cdo2.getColValue("tipo_docto").equals("AJUSTE")) ajuste += Double.parseDouble(cdo2.getColValue("monto"));

					
					
					
				%>
        <%=fb.hidden("secuencia_pago"+i,cdo2.getColValue("secuencia_pago"))%>
        <%=fb.hidden("tran_anio"+i,cdo2.getColValue("tran_anio"))%>
        <%=fb.hidden("codigo_transaccion"+i,cdo2.getColValue("codigo_transaccion"))%>
        <%=fb.hidden("facCodigo"+i,cdo2.getColValue("fac_codigo"))%>
        <%=fb.hidden("admision"+i,cdo2.getColValue("admi_secuencia"))%>
        <tr class="TextRow01">
          <td align="center"><%=cdo2.getColValue("pago_por_desc")%></td>
          <td align="center"><%if(cdo2.getColValue("fac_codigo")!= null && !cdo2.getColValue("fac_codigo").trim().equals("")&& !cdo2.getColValue("fac_codigo").trim().equals("0")){%><a href="javascript:printFact(<%=i%>)" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><%=cdo2.getColValue("fac_codigo")%><%}%></td>
          <td align="center"><%=cdo2.getColValue("admi_secuencia")%></td>
          <td align="center"><%=cdo2.getColValue("fecha")%> - <%=cdo2.getColValue("usuario")%></td>
          <td align="left"><%=cdo2.getColValue("nombre_paciente")%></td>
          <td align="center"><%=cdo2.getColValue("tipo_transaccion_desc")%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal("###,###,##0.##",cdo2.getColValue("monto"))%></td>
          <td align="center"><%=cdo2.getColValue("secuencia_pago")%></td>
          <td align="center"><%if(cdo2.getColValue("tipo_docto").equalsIgnoreCase("PAGO")){%><a href="javascript:verDist(<%=i%>);"><font class="Link00">Ver Dist.</font></a><%}%></td>
        </tr>
        <%
				}
				
		double saldoReal =  (total_pago - pago +(ajuste+(ajusteDb+ajusteCr)));
	
			%>

				<tr class="TextRow01">
						<td colspan="5" align="right" class="TextHeader02"><cellbytelabel>T   O   T   A   L  &nbsp;&nbsp;&nbsp;&nbsp;P   A   G   A   D   O</cellbytelabel>:&nbsp;&nbsp;&nbsp;</td>
						<td colspan="2"  align="right" class="TextHeader02">B/.&nbsp;<%=CmnMgr.getFormattedDecimal("###,###,##0.##",total_pago)%>&nbsp;</td>
						<td colspan="2" class="TextHeader02">&nbsp;</td>
				</tr>
				<tr class="TextRow01">
						<td align="right" colspan="5">
						T&nbsp;O&nbsp;T&nbsp;A&nbsp;L&nbsp;&nbsp;&nbsp;A&nbsp;P&nbsp;L&nbsp;I&nbsp;C&nbsp;A&nbsp;D&nbsp;O&nbsp;.&nbsp;.&nbsp;.
						<td colspan="2"  align="right" class="Text12Bold">B/.&nbsp;<%=CmnMgr.getFormattedDecimal("###,###,##0.##",pago)%>&nbsp;</td>
						<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow01">
						<td align="right" colspan="5">
						A&nbsp;J&nbsp;U&nbsp;S&nbsp;T&nbsp;E&nbsp;&nbsp;&nbsp;DB&nbsp;.&nbsp;.&nbsp;.
						<td colspan="2"  align="right" class="Text12Bold">B/.&nbsp;<%=CmnMgr.getFormattedDecimal("###,###,##0.##",(ajuste+ajusteDb))%>&nbsp;</td>
						<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow01">
						<td align="right" colspan="5">
						A&nbsp;J&nbsp;U&nbsp;S&nbsp;T&nbsp;E&nbsp;&nbsp;&nbsp;CR&nbsp;.&nbsp;.&nbsp;.
						<td colspan="2"  align="right" class="Text12Bold">B/.&nbsp;<%=CmnMgr.getFormattedDecimal("###,###,##0.##",ajusteCr)%>&nbsp;</td>
						<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow01">
						<td align="right" colspan="5">
						BALANCE&nbsp;.&nbsp;.&nbsp;.
						<td colspan="2"  align="right" class="Text12Bold">B/.&nbsp;<%=CmnMgr.getFormattedDecimal("###,###,##0.##",saldoReal)%>&nbsp;</td>
						<td colspan="2">&nbsp;</td>
				</tr>

				<tr class="TextHeader02">
					<td colspan="9"><cellbytelabel>S</cellbytelabel>&nbsp;<cellbytelabel>A</cellbytelabel>&nbsp;<cellbytelabel>L</cellbytelabel>&nbsp;<cellbytelabel>D</cellbytelabel>&nbsp;<cellbytelabel>O</cellbytelabel>&nbsp;&nbsp;&nbsp;<cellbytelabel>E</cellbytelabel>&nbsp;<cellbytelabel>N</cellbytelabel>&nbsp;&nbsp;&nbsp;<cellbytelabel>R</cellbytelabel>&nbsp;<cellbytelabel>E</cellbytelabel>&nbsp;<cellbytelabel>C</cellbytelabel>&nbsp;<cellbytelabel>I</cellbytelabel>&nbsp;<cellbytelabel>B</cellbytelabel>&nbsp;<cellbytelabel>O</cellbytelabel></td>
				</tr>
        <tr class="TextRow01">
          <td align="left" colspan="2"><cellbytelabel>TOTAL APLICADO</cellbytelabel>:&nbsp;&nbsp;&nbsp;</td>
          <td colspan="2" align="right" class="Text12Bold"><%=CmnMgr.getFormattedDecimal("###,###,##0.##",pago)%>&nbsp;&nbsp;&nbsp;
          <td align="right" ><cellbytelabel>TOTAL APLICADO POR AJUSTES</cellbytelabel>:&nbsp;&nbsp;&nbsp;</td>
          <td class="Text12Bold"><%=CmnMgr.getFormattedDecimal("###,###,##0.##",ajuste)%>&nbsp;</td>
          <td>=</td>
          <td align="right" colspan="2" class="Text12Bold"><%=CmnMgr.getFormattedDecimal("###,###,##0.##",pago+ajuste)%></td>
        </tr>
        <%=fb.formEnd(true)%>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
      </table></td>
  </tr>
</table>
</body>
</html>
<%
}//GET
else
{
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
parent.document.formRecibo.submit();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
