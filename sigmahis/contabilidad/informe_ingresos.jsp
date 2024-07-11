<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="_companyId" scope="session" class="java.lang.String" />
<jsp:useBean id="htT" scope="page" class="java.util.Hashtable" />
<%
/*
==========================================================================================
==========================================================================================
*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alT = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbSqlAll = new StringBuffer();
String appendFilter = "";
String compId = _companyId;
String fg = request.getParameter("fg");
String fecha_desde = request.getParameter("fecha_desde");
String fecha_hasta = request.getParameter("fecha_hasta");
String filtrado_por = request.getParameter("filtrado_por");
String client_name = request.getParameter("client_name");
String no_factura = request.getParameter("no_factura");
String cajero = request.getParameter("cajero");
String turno = request.getParameter("turno");
String tipo = request.getParameter("tipo");
String tipo_cliente = request.getParameter("tipo_cliente");
if(tipo==null) tipo="";
if(tipo_cliente==null) tipo_cliente="";
if(fecha_desde==null) fecha_desde="";
if(fecha_hasta==null) fecha_hasta="";
if(fg == null) fg = "";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	/*
	CommonDataObject cdoF = SQLMgr.getData("select '01/'||to_char(sysdate, 'mm/yyyy') fecha_desde, to_char(sysdate, 'dd/mm/yyyy') fecha_hasta from dual");
	if(fecha_desde==null || fecha_desde.equals("")) fecha_desde = cdoF.getColValue("fecha_desde");
	if(fecha_hasta==null || fecha_hasta.equals("")) fecha_hasta = cdoF.getColValue("fecha_hasta");
  */
	int recsPerPage = 1000;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  if (request.getParameter("searchQuery") != null){
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }
	
	if(request.getParameter("client_name")==null) client_name = "";
	if(request.getParameter("no_factura")==null) no_factura = "";
	if(cajero==null) cajero = "";
	if(turno==null) turno = "";
	
  sbSql.append("select a.* from (");
	sbSql.append("select 'OI' tipo_doc, t.doc_type, doc_no, doc_date fecha, to_char(doc_date, 'dd/mm/yyyy') doc_date, client_name, (nvl(decode(t.doc_type, 'NCR', -gross_amount, gross_amount), 0) + nvl(decode(t.doc_type, 'NCR', -gross_amount_gravable, gross_amount_gravable), 0) - nvl(decode(t.doc_type, 'NCR', -total_discount, total_discount), 0) - nvl(decode(t.doc_type, 'NCR', -total_discount_gravable, total_discount_gravable), 0)) total_venta, decode(tipo_factura, 'CO', decode(t.doc_type, 'NCR', -(sub_total+total_discount), (sub_total+total_discount)), 0) co_no_gravable, decode(tipo_factura, 'CO', decode(t.doc_type, 'NCR', -(sub_total_gravable+total_discount_gravable), (sub_total_gravable+total_discount_gravable)), 0) co_gravable, decode(tipo_factura, 'CO', decode(t.doc_type, 'NCR', -tax_amount, tax_amount), 0) co_tax_amount, nvl(decode(tipo_factura, 'CR', decode(t.doc_type, 'NCR', -(sub_total+total_discount), (sub_total+total_discount)), 0),0) cr_no_gravable, decode(tipo_factura, 'CR', decode(t.doc_type, 'NCR', -(sub_total_gravable+total_discount_gravable), (sub_total_gravable+total_discount_gravable)), 0) cr_gravable, decode(tipo_factura, 'CR', decode(t.doc_type, 'NCR', -tax_amount, tax_amount), 0) cr_tax_amount, decode(t.doc_type, 'NCR', -net_amount, net_amount) net_amount, (case when t.tipo_factura = 'CO' and doc_type = 'NCR' then -t.net_amount else nvl((select sum(monto) from tbl_cja_detalle_pago dp where dp.compania = t.company_id and dp.fac_codigo = t.other3 and t.doc_type = 'FAC'), 0) end) pago, to_number(to_number(substr(t.other3,decode(instr(t.other3,'-'),0,0,instr(t.other3,'-')+1),length(t.other3)))) cod_factura, nvl(decode(t.doc_type, 'NCR', - (nvl(total_discount, 0) + nvl(total_discount_gravable, 0)), nvl(total_discount, 0) + nvl(total_discount_gravable, 0)), 0) descuento, (select to_char(id) from tbl_fac_dgi_documents d where d.tipo_docto in ('FACP', 'NCP') and d.compania = t.company_id and codigo = T.other3 and decode(d.tipo_docto, 'FACP', 'FAC', 'NCP', 'NCR') = t.doc_type) dgi_id, t.status,decode (tipo_factura, 'CO', decode(t.doc_type, 'NCR', -(total_discount_gravable), (total_discount_gravable)), 0) descuento_co ,decode (tipo_factura, 'CR', decode(t.doc_type, 'NCR', -(total_discount_gravable), (total_discount_gravable)), 0) descuento_cr   from tbl_fac_trx t where company_id = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	if(!cajero.equals("")){
		sbSql.append(" and cod_cajero = '");
		sbSql.append(cajero);
		sbSql.append("'");
	}
	if(!turno.equals("")){
		sbSql.append(" and turno = ");
		sbSql.append(turno);
	}
	if(!fecha_desde.equals("")){
		sbSql.append(" and doc_date >= to_date('");
		sbSql.append(fecha_desde);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!fecha_hasta.equals("")){
		sbSql.append(" and doc_date <= to_date('");
		sbSql.append(fecha_hasta);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!no_factura.equals("")){
		sbSql.append(" and other3 = '");
		sbSql.append(no_factura);
		sbSql.append("'");
	}	
	if(!tipo_cliente.equals("")){
		sbSql.append(" and client_ref_id = ");
		sbSql.append(tipo_cliente);
	}	
	
	sbSql.append(" union ");
	sbSql.append("select 'SH' tipo_doc, 'FAC' doc_type, codigo doc_no, fecha, to_char(fecha, 'dd/mm/yyyy') doc_date, (case when t.facturar_a = 'P' then (select nombre_paciente from vw_adm_paciente vp where vp.pac_id = t.pac_id) else (select nombre from tbl_adm_empresa e where e.codigo = t.cod_empresa) end) client_name, monto_total total_venta, nvl(decode(tipo, 'CO', monto_total + nvl(monto_descuento, 0) + nvl(monto_descuento2, 0)), 0) co_no_gravable, 0 co_gravable, 0 co_tax_amount, nvl(decode(tipo, 'CR', monto_total + nvl(monto_descuento, 0) + nvl(monto_descuento2, 0)),0) cr_no_gravable, 0 cr_gravable, 0 cr_tax_amount, monto_total, nvl((select sum(monto) from tbl_cja_detalle_pago dp where dp.compania = t.compania and dp.fac_codigo = t.codigo), 0) pago, to_number(substr(codigo,decode(instr(codigo,'-'),0,0,instr(codigo,'-')+1),length(codigo))) cod_factura, (nvl(monto_descuento, 0) + nvl(monto_descuento2, 0)) descuento, t.codigo dgi_id, decode(t.estatus, 'A', 'I', 'O') status,0,0 from tbl_fac_factura t/*, (select f.compania, f.fac_codigo, sum(monto) monto from tbl_fac_detalle_factura f where  exists (select null from tbl_cds_centro_servicio cds where cds.codigo = f.centro_servicio and cds.tipo_cds = 'T' and cds.codigo != 0) group by f.compania, f.fac_codigo) df, (select df.compania, df.fac_codigo, sum(monto) copago from tbl_fac_detalle_factura df where tipo_cobertura = 'CO' group by df.compania, df.fac_codigo) co*/ where t.compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and t.facturar_a in ('P', 'E') /*and t.estatus != 'A'*/ and nvl(t.comentario, 'N') !='S/I' /*and t.compania = df.compania(+) and t.codigo = df.fac_codigo(+) and t.compania = co.compania(+) and t.codigo = co.fac_codigo(+)*/");
	if(!cajero.equals("") || !turno.equals("")){
		sbSql.append(" and exists (select null from tbl_cja_transaccion_pago p, tbl_cja_detalle_pago dp, tbl_cja_turnos ct where p.codigo = dp.codigo_transaccion and p.compania = dp.compania and p.anio = dp.tran_anio and dp.fac_codigo = t.codigo and p.compania = ct.compania and p.turno = ct.codigo");
		if(!cajero.equals("")){
			sbSql.append(" and cja_cajera_cod_cajera = '");
			sbSql.append(cajero);
			sbSql.append("'");
		}
		if(!turno.equals("")){
			sbSql.append(" and turno = ");
			sbSql.append(turno);
		}
		sbSql.append(")");
	}
	if(!fecha_desde.equals("")){
		sbSql.append(" and fecha >= to_date('");
		sbSql.append(fecha_desde);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!fecha_hasta.equals("")){
		sbSql.append(" and fecha <= to_date('");
		sbSql.append(fecha_hasta);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!no_factura.equals("")){
		sbSql.append(" and codigo = '");
		sbSql.append(no_factura);
		sbSql.append("'");
	}	
	if(!tipo_cliente.equals("")){
		sbSql.append(" and cliente_otros = ");
		sbSql.append(tipo_cliente);
	}	
	
	sbSql.append(" union select 'SH' tipo_doc, decode(a.lado_mov, 'C', 'NCR', 'NDB') doc_type, to_char(nota_ajuste) doc_no, a.fecha, to_char (a.fecha, 'dd/mm/yyyy') doc_date, getnombrecliente(a.compania, ref_type, ref_id) client_name, decode(a.lado_mov, 'C', -monto, monto) total_venta, decode(f.tipo, 'CO', nvl (decode(a.lado_mov, 'C', -monto, monto), 0), 0) co_no_gravable, 0 co_gravable, 0 co_tax_amount, nvl(decode(f.tipo, 'CR', nvl (decode(a.lado_mov, 'C', -monto, monto), 0), 0),0) cr_no_gravable, 0 cr_gravable, 0 cr_tax_amount, decode(a.lado_mov, 'C', -monto, monto) monto_total, nvl ((select   sum (monto) from tbl_cja_detalle_pago dp where dp.compania = f.compania and dp.fac_codigo = f.codigo), 0) pago, to_number(substr(f.codigo,decode(instr(f.codigo,'-'),0,0,instr(f.codigo,'-')+1),length(f.codigo))) cod_factura, 0 descuento, f.codigo dgi_id, decode (f.estatus, 'A', 'I', 'O') status,0, 0 from (select lado_mov, nota_ajuste, fecha_aprob_idx as fecha, compania, ref_type, ref_id, factura, sum(monto) monto,tipo_doc from vw_con_adjustment_gral group by lado_mov, nota_ajuste, fecha_aprob_idx, compania, ref_type, ref_id, factura,tipo_doc ) a, tbl_fac_Factura f where a.compania = f.compania and a.factura = f.codigo and a.tipo_doc='F' and f.compania =");
	sbSql.append((String) session.getAttribute("_companyId"));
		
	if(!cajero.equals("") || !turno.equals("")){
		sbSql.append(" and exists (select null from tbl_cja_transaccion_pago p, tbl_cja_detalle_pago dp, tbl_cja_turnos ct where p.codigo = dp.codigo_transaccion and p.compania = dp.compania and p.anio = dp.tran_anio and dp.fac_codigo = f.codigo and p.compania = ct.compania and p.turno = ct.codigo");
		if(!cajero.equals("")){
			sbSql.append(" and cja_cajera_cod_cajera = '");
			sbSql.append(cajero);
			sbSql.append("'");
		}
		if(!turno.equals("")){
			sbSql.append(" and turno = ");
			sbSql.append(turno);
		}
		sbSql.append(")");
	}
	if(!fecha_desde.equals("")){
		sbSql.append(" and a.fecha >= to_date('");
		sbSql.append(fecha_desde);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!fecha_hasta.equals("")){
		sbSql.append(" and a.fecha <= to_date('");
		sbSql.append(fecha_hasta);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!no_factura.equals("")){
		sbSql.append(" and f.codigo = '");
		sbSql.append(no_factura);
		sbSql.append("'");
	}	
	if(!tipo_cliente.equals("")){
		sbSql.append(" and f.cliente_otros = ");
		sbSql.append(tipo_cliente);
	}	
	
	sbSql.append(") a where tipo_doc is not null");
	if(!client_name.equals("")){
		sbSql.append(" and client_name like '%");
		sbSql.append(client_name);
		sbSql.append("%'");
	}
	if(!tipo.equals("")){
		sbSql.append(" and tipo_doc = '");
		sbSql.append(tipo);
		sbSql.append("'");
	}
	sbSql.append(" order by 16 desc, 1");


  sbSqlAll.append("select * from (select rownum as rn, a.* from (");
	sbSqlAll.append(sbSql.toString());
	sbSqlAll.append(") a) where rn between ");
	sbSqlAll.append(previousVal);
	sbSqlAll.append(" and ");
	sbSqlAll.append(nextVal);
	if(!fecha_desde.equals("") && !fecha_hasta.equals("")){
  al = SQLMgr.getDataList(sbSqlAll.toString());
  rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql.toString()+") z");
	sbSqlAll = new StringBuffer();
	sbSqlAll.append("select tipo_doc, sum(total_venta) total_venta, sum(co_no_gravable) co_no_gravable, sum(co_gravable) co_gravable, sum(co_tax_amount) co_tax_amount, sum(cr_no_gravable) cr_no_gravable, sum(cr_gravable) cr_gravable,  sum(cr_tax_amount) cr_tax_amount, sum(net_amount) net_amount, sum(pago) pago, sum(descuento) descuento from (");
	sbSqlAll.append(sbSql.toString());
	sbSqlAll.append(") group by tipo_doc");
	/*alT = SQLMgr.getDataList(sbSqlAll.toString());
	for(int i = 0; i<alT.size();i++){
		CommonDataObject ct = (CommonDataObject) alT.get(i);
		htT.put(ct.getColValue("tipo_doc"), ct);
	}*/
	}
	
  
  if (searchDisp!=null) searchDisp=searchDisp;
  else searchDisp = "Listado";
  
  if (!searchVal.equals("")) searchValDisp=searchVal;
  else searchValDisp="Todos";

  int nVal, pVal;
  int preVal=Integer.parseInt(previousVal);
  int nxtVal=Integer.parseInt(nextVal);
  
  if (nxtVal<=rowCount) nVal=nxtVal;
  else nVal=rowCount;
  
  if(rowCount==0) pVal=0;
  else pVal=preVal;
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Informe de ingresos - '+document.title;

function printList()
{	
	abrir_ventana('');
}

function showReport(){
	var fDate 			= document.search01.fecha_desde.value;
	var tDate 			= document.search01.fecha_hasta.value;
	var client_name 		= document.search01.client_name.value;
	var no_factura 			= document.search01.no_factura.value;
	var cajero 			= document.search01.cajero.value;
	var turno 			= document.search01.turno.value;
	var tipo 			= document.search01.tipo.value;
	var tipo_cliente 			= document.search01.tipo_cliente.value;
	var pCtrlHeader = document.search01.pCtrlHeader.checked;
	abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=pos/informe_diario_ingreso.rptdesign&cltNameParam='+client_name+'&noFacturaParam='+no_factura+'&fechaDesdeParam='+fDate+'&fechaHastaParam='+tDate+'&pCtrlHeader='+pCtrlHeader+'&cajeroParam='+cajero+'&turnoParam='+turno+'&tipoParam='+tipo+'&tipoClteParam='+tipo_cliente);
}

function showTurno()
{
var cajero = document.search01.cajero.value ;
if(cajero=='') alert('Seleccione Cajero!');
else abrir_ventana2('../caja/turnos_list.jsp?fp=informe_ingresos&cod_cajera='+cajero);
}

function showDoc(tipo, codigo){
	if(tipo=='SH') abrir_ventana('../facturacion/print_factura.jsp?factura='+codigo+'&compania=<%=(String) session.getAttribute("_companyId")%>');
	else abrir_ventana('../facturacion/ver_impresion_dgi.jsp?docId='+codigo);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value=""></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td><!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
      <table width="100%" cellpadding="0" cellspacing="0">
        <tr class="RedTextBold"><td>Este reporte no contempla Centros Terceros configurados en Centros de Servicio</td></tr>
				<tr class="TextFilter">
          <%
					  fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
          <%=fb.formStart()%> 
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> 
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%> 
					<%=fb.hidden("fg",fg)%>
          <td>Fecha: 
          <jsp:include page="../common/calendar.jsp" flush="true">
          <jsp:param name="noOfDateTBox" value="2" />
          <jsp:param name="clearOption" value="true" />
          <jsp:param name="nameOfTBox1" value="fecha_desde" />
          <jsp:param name="valueOfTBox1" value="<%=fecha_desde%>" />
          <jsp:param name="nameOfTBox2" value="fecha_hasta" />
          <jsp:param name="valueOfTBox2" value="<%=fecha_hasta%>" />
          </jsp:include>
					&nbsp;&nbsp;
					Cliente:
					<%=fb.textBox("client_name",client_name,false,false,false,40,"Text10",null,"")%> 
          &nbsp;&nbsp;
					No. Factura:
					<%=fb.textBox("no_factura",no_factura,false,false,false,12,"Text10",null,"")%> 
					Cajero:
					<%=fb.select(ConMgr.getConnection(),"select cod_cajera, lpad(cod_cajera, 3, '0') ||' - ' || nombre descripcion from tbl_cja_cajera where compania = "+(String) session.getAttribute("_companyId")+" order by nombre asc","cajero",cajero,false,false,0,"text10",null,"", "", "S")%>
  				Turno:
					<%=fb.textBox("turno",turno,false,false,false,5)%>
					<%=fb.button("addTurno","...",true,false,null,null,"onClick=\"javascript:showTurno()\"","Seleccionar Turno")%>
					Tipo:
					<%=fb.select("tipo","SH=Servicios Hospitalarios, OI=Otros Ingresos",tipo,false,false,0,"Text12",null,"",null,"T")%>
					Tipo Cliente:
					<%=fb.select(ConMgr.getConnection(),"select codigo, codigo ||' - ' || descripcion descripcion from tbl_fac_tipo_cliente where compania = "+(String) session.getAttribute("_companyId")+" order by descripcion asc","tipo_cliente",tipo_cliente,false,false,0,"text10",null,"", "", "S")%>
          <%=fb.submit("go","Ir")%> 
					Esconder Header
					<%=fb.checkbox("pCtrlHeader","")%>
          </td>
          <%=fb.formEnd()%> </tr>
      </table>
      <!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
    </td>
  </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableLeftBorder TableTopBorder TableRightBorder"><table align="center" width="100%" cellpadding="1" cellspacing="0">
        <tr class="TextPager">
          <%
				fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
          <%=fb.formStart()%> 
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> 
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%> 
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%> 
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%> 
					<%=fb.hidden("searchOn",searchOn)%> 
					<%=fb.hidden("searchVal",searchVal)%> 
					<%=fb.hidden("searchValFromDate",searchValFromDate)%> 
					<%=fb.hidden("searchValToDate",searchValToDate)%> 
					<%=fb.hidden("searchType",searchType)%> 
					<%=fb.hidden("searchDisp",searchDisp)%> 
					<%=fb.hidden("searchQuery","sQ")%> 
					<%=fb.hidden("no_factura",no_factura)%> 
					<%=fb.hidden("client_name",client_name)%> 
					<%=fb.hidden("fecha_desde",fecha_desde)%> 
					<%=fb.hidden("fecha_hasta",fecha_hasta)%> 
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("cajero",cajero)%>
					<%=fb.hidden("turno",turno)%>
					<%=fb.hidden("tipo",tipo)%>
					<%=fb.hidden("tipo_cliente",tipo_cliente)%>
          <td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
          <%=fb.formEnd()%>
          <td width="40%">Total Registro(s) <%=rowCount%></td>
          <td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
          <%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
          <%=fb.formStart()%> 
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> 
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%> 
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%> 
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%> 
					<%=fb.hidden("searchOn",searchOn)%> 
					<%=fb.hidden("searchVal",searchVal)%> 
					<%=fb.hidden("searchValFromDate",searchValFromDate)%> 
					<%=fb.hidden("searchValToDate",searchValToDate)%> 
					<%=fb.hidden("searchType",searchType)%> 
					<%=fb.hidden("searchDisp",searchDisp)%> 
					<%=fb.hidden("searchQuery","sQ")%> 
					<%=fb.hidden("no_factura",no_factura)%> 
					<%=fb.hidden("client_name",client_name)%> 
					<%=fb.hidden("fecha_desde",fecha_desde)%> 
					<%=fb.hidden("fecha_hasta",fecha_hasta)%> 
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("cajero",cajero)%>
					<%=fb.hidden("turno",turno)%>
					<%=fb.hidden("tipo",tipo)%>
					<%=fb.hidden("tipo_cliente",tipo_cliente)%>
          <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
          <%=fb.formEnd()%> </tr>
      </table></td>
  </tr>
	<tr>
		<td align="right"><table align="center" width="100%" cellpadding="0" cellspacing="1">
        <tr>
					<td class="YellowText">&nbsp;* Documentos Anulados</td>
					<td class="RedText">&nbsp;* Notas de Cr&eacute;dito</td>
					<td align="right"><authtype type='0'><a href="javascript:showReport()" class="Link00">[ Reporte ]</a></authtype></td>
				</tr>
		</table>
	</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableLeftBorder TableRightBorder"><!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
      <table align="center" width="100%" cellpadding="0" cellspacing="1">
        <tr class="TextHeader" align="center">
					<td rowspan="2" width="2%">Tipo</td>
					<td rowspan="2" width="7%">No. Factura</td>
					<td rowspan="2" width="7%">Fecha</td>
					<td rowspan="2" width="18%">Nombre de Cliente</td>
					<td rowspan="2" width="8%">Total Venta</td>
					<td colspan="2" width="15">Venta Contado</td>
					<td rowspan="2" width="4%">DESC.</td>
					<td rowspan="2" width="4%">ITBM</td>
					<td colspan="2" width="17%">Venta Credito</td>
					<td rowspan="2" width="4%">DESC.</td>
					<td rowspan="2" width="4%">ITBM</td>
					<td rowspan="2" width="4%">Descuento</td>
					<td rowspan="2" width="10%">Ctas x Cobrar</td>
					<td rowspan="2" width="5%">Pagos</td>
				</tr>
        <tr class="TextHeader" align="center">
					<td >No Gravable</td>
					<td >Gravable</td>
					<td >No Gravable</td>
					<td >Gravable</td>
				</tr>
				<%
				String tipo_doc = "";
				double total_venta = 0.00, co_no_gravable = 0.00, co_gravable = 0.00, co_tax_amount = 0.00, cr_no_gravable = 0.00, cr_gravable = 0.00, cr_tax_amount = 0.00, descuento = 0.00, net_amount = 0.00,desc_co=0.00, pago = 0.00,desc=0.00; 
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				  
				if(cdo.getColValue("doc_type").equals("NCR")) color = "RedText";
				if(cdo.getColValue("status").equals("I")) color = "YellowText";
				%>
        <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
          <td><%=cdo.getColValue("tipo_doc")%></td>
					<td align="center"><a href="javascript:showDoc('<%=cdo.getColValue("tipo_doc")%>','<%=cdo.getColValue("dgi_id")%>')" class="Link00 Text10"><%=cdo.getColValue("cod_factura")%></a></td>
          <td><%=cdo.getColValue("doc_date")%></td>
          <td><%=cdo.getColValue("client_name")%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("total_venta"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("co_no_gravable"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("co_gravable"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("descuento_co"))%></td>
		  <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("co_tax_amount"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("cr_no_gravable"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("cr_gravable"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("descuento_cr"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("cr_tax_amount"))%></td>		  
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("descuento"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("net_amount"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("pago"))%></td>
        </tr>
        <%System.out.println("cr_no_gravable == "+cdo.getColValue("cr_no_gravable"));
					tipo_doc = cdo.getColValue("tipo_doc");
					if(!cdo.getColValue("status").equals("I")){
					total_venta += Double.parseDouble(cdo.getColValue("total_venta")); 
					co_no_gravable += Double.parseDouble(cdo.getColValue("co_no_gravable"));
					co_gravable += Double.parseDouble(cdo.getColValue("co_gravable"));
					co_tax_amount += Double.parseDouble(cdo.getColValue("co_tax_amount"));
					cr_no_gravable += Double.parseDouble(cdo.getColValue("cr_no_gravable"));
					cr_gravable += Double.parseDouble(cdo.getColValue("cr_gravable"));
					cr_tax_amount += Double.parseDouble(cdo.getColValue("cr_tax_amount"));
					descuento += Double.parseDouble(cdo.getColValue("descuento_cr"));
					desc_co += Double.parseDouble(cdo.getColValue("descuento_co"));
					desc += Double.parseDouble(cdo.getColValue("descuento"));
					net_amount += Double.parseDouble(cdo.getColValue("net_amount"));
					pago += Double.parseDouble(cdo.getColValue("pago"));
					}
				}
				%>
        <%
					if(al.size()!=0){
						//CommonDataObject ct = (CommonDataObject) htT.get(tipo_doc);
				%>
				<tr class="Text10Bold">
          <td colspan="4" align="right">Total:</td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(total_venta)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(co_no_gravable)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(co_gravable)%></td>
		  <td align="right"><%=CmnMgr.getFormattedDecimal(desc_co)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(co_tax_amount)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cr_no_gravable)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cr_gravable)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(descuento)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cr_tax_amount)%></td>
		  <td align="right"><%=CmnMgr.getFormattedDecimal(desc)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(net_amount)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(pago)%></td>
        </tr>
				<%}%>
     </table>
      <!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
    </td>
  </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableLeftBorder TableBottomBorder TableRightBorder"><table align="center" width="100%" cellpadding="1" cellspacing="0">
        <tr class="TextPager">
          <%
				fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
          <%=fb.formStart()%> 
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> 
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%> 
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%> 
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%> 
					<%=fb.hidden("searchOn",searchOn)%> 
					<%=fb.hidden("searchVal",searchVal)%> 
					<%=fb.hidden("searchValFromDate",searchValFromDate)%> 
					<%=fb.hidden("searchValToDate",searchValToDate)%> 
					<%=fb.hidden("searchType",searchType)%> 
					<%=fb.hidden("searchDisp",searchDisp)%> 
					<%=fb.hidden("searchQuery","sQ")%> 
					<%=fb.hidden("no_factura",no_factura)%> 
					<%=fb.hidden("client_name",client_name)%> 
					<%=fb.hidden("fecha_desde",fecha_desde)%> 
					<%=fb.hidden("fecha_hasta",fecha_hasta)%> 
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("cajero",cajero)%>
					<%=fb.hidden("turno",turno)%>
					<%=fb.hidden("tipo",tipo)%>
					<%=fb.hidden("tipo_cliente",tipo_cliente)%>
          <td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
          <%=fb.formEnd()%>
          <td width="40%">Total Registro(s) <%=rowCount%></td>
          <td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
          <%
					fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
          <%=fb.formStart()%> 
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> 
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%> 
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%> 
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%> 
					<%=fb.hidden("searchOn",searchOn)%> 
					<%=fb.hidden("searchVal",searchVal)%> 
					<%=fb.hidden("searchValFromDate",searchValFromDate)%> 
					<%=fb.hidden("searchValToDate",searchValToDate)%> 
					<%=fb.hidden("searchType",searchType)%> 
					<%=fb.hidden("searchDisp",searchDisp)%> 
					<%=fb.hidden("searchQuery","sQ")%> 
					<%=fb.hidden("no_factura",no_factura)%> 
					<%=fb.hidden("client_name",client_name)%> 
					<%=fb.hidden("fecha_desde",fecha_desde)%> 
					<%=fb.hidden("fecha_hasta",fecha_hasta)%> 
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("cajero",cajero)%>
					<%=fb.hidden("turno",turno)%>
					<%=fb.hidden("tipo",tipo)%>
					<%=fb.hidden("tipo_cliente",tipo_cliente)%>
          <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
          <%=fb.formEnd()%> </tr>
      </table></td>
  </tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
