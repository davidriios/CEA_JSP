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
String grupo_empresa = request.getParameter("grupo_empresa");
String empresa = request.getParameter("empresa");
String empresa_desc = request.getParameter("empresa_desc");
String categoria = request.getParameter("categoria");
String ref_type = request.getParameter("ref_type");

if(fg == null) fg = "";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	CommonDataObject cdoF = SQLMgr.getData("select '01/'||to_char(sysdate, 'mm/yyyy') fecha_desde, to_char(sysdate, 'dd/mm/yyyy') fecha_hasta from dual");
	if(fecha_desde==null || fecha_desde.equals("")) fecha_desde = cdoF.getColValue("fecha_desde");
	if(fecha_hasta==null || fecha_hasta.equals("")) fecha_hasta = cdoF.getColValue("fecha_hasta");
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
	if(grupo_empresa==null) grupo_empresa = "";
	if(empresa==null) empresa = "";
	if(categoria==null) categoria = "";
	if(ref_type==null) ref_type = "";
	
  sbSql.append("select a.*, decode(adm_type, 'I', 'IP', 'O', 'OP', 'NA') adm_type_desc from (select 'IF' tipo, e.grupo_empresa, a.compania, a.facturar_a ref_type, decode (a.facturar_a, 'P', a.pac_id, 'E', a.cod_empresa) ref_code, a.codigo doc_id, a.codigo doc_no, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.fecha doc_date, a.pac_id, a.admi_secuencia admision, a.cod_empresa empresa, a.codigo aplica_a, 'F' grupo_empresa_desc_aplica, a.comentario descripcion, decode ( a.facturar_a, 'P', to_number (get_sec_comp_param (a.compania, 'TP_CLIENTE_PAC')), 'E', to_number (get_sec_comp_param (a.compania, 'TP_CLIENTE_EMP'))) refer_type, decode (a.facturar_a, 'P', a.pac_id, 'E', a.cod_empresa) refer_id, (case when a.facturar_a = 'P' then (select p.primer_nombre || decode (p.segundo_nombre, null, '', ' ' || p.segundo_nombre) || decode (p.primer_apellido, null, '', ' ' || p.primer_apellido) || decode (p.segundo_apellido, null, '', ' ' || p.segundo_apellido) || decode (p.sexo, 'F', decode (p.apellido_de_casada, null, '', ' ' || p.apellido_de_casada)) from tbl_adm_paciente p where p.pac_id = a.pac_id) else a.nombre_cliente end) nombre_cliente, /*(a.grang_total+nvl(a.monto_descuento, 0)+nvl(monto_descuento2, 0))*/ (a.subtotal - nvl(a.monto_paciente, 0) + nvl(h.monto, 0)) total_bruto, -(nvl(a.monto_descuento, 0)+nvl(monto_descuento2, 0)+nvl(monto_descuento_hon, 0)) descuento, nvl (b.ajuste, 0) ajuste, nvl (c.monto, 0) monto_centro_tercero, /*(a.grang_total+nvl(b.ajuste, 0)-nvl (c.monto, 0)+nvl(f.ajuste_centro_iii, 0))*/ (a.subtotal +nvl(h.monto, 0)-(nvl(a.monto_descuento, 0)+nvl(monto_descuento2, 0)+nvl(monto_descuento_hon, 0)) - nvl(a.monto_paciente, 0) +nvl(b.ajuste, 0)) total_neto, nvl((select descripcion from tbl_adm_grupo_empresa ge where ge.codigo = e.grupo_empresa), '') grupo_empresa_desc, nvl((select descripcion from tbl_adm_tipo_empresa ge where ge.codigo = e.tipo_empresa), '') tipo_empresa_desc, nvl(e.nombre, '') aseguradora_desc, nvl(f.ajuste_centro_iii, 0)-nvl(d.monto, 0) ajuste_centro_iii, nvl((select sum(monto) from tbl_cja_detalle_pago dp where dp.compania = a.compania and dp.anulada = 'N' and dp.fac_codigo = a.codigo), 0) pagado, a.adm_type from tbl_fac_factura a, (select a.compania, a.factura, nvl(sum(decode(a.lado_mov, 'D', a.monto, 0)), 0)-nvl(sum(decode(a.lado_mov, 'C', a.monto, 0)), 0) ajuste from vw_con_adjustment_gral a where a.tipo_ajuste not in (select codigo from tbl_fac_tipo_ajuste where compania = a.compania and group_type = 'E') /*and not exists (select null from tbl_cds_centro_servicio cds where cds.codigo = a.centro and cds.tipo_cds = 'T')*/ group by a.compania, a.factura) b, (select compania, fac_codigo, sum (monto + nvl(descuento, 0)) monto from tbl_fac_detalle_factura df where exists (select null from   tbl_cds_centro_servicio cds where   cds.codigo = df.centro_servicio and cds.tipo_cds = 'T') group by compania, fac_codigo) c, (select compania, fac_codigo, sum (monto+descuento) monto from tbl_fac_detalle_factura df where centro_servicio = 0 group by compania, fac_codigo) h, (select compania, fac_codigo, sum (nvl(descuento, 0)) monto from tbl_fac_detalle_factura df where exists (select null from   tbl_cds_centro_servicio cds where   cds.codigo = df.centro_servicio and cds.tipo_cds = 'T') group by compania, fac_codigo) d, tbl_adm_empresa e, (select a.compania, a.factura, nvl(sum(decode(a.lado_mov, 'D', a.monto, 0)), 0) - nvl(sum(decode(a.lado_mov, 'C', a.monto, 0)), 0) ajuste_centro_iii from vw_con_adjustment_gral a where a.tipo_ajuste not in (select codigo from tbl_fac_tipo_ajuste where compania = a.compania and group_type = 'E') and exists (select null from tbl_cds_centro_servicio cds where cds.codigo = a.centro and cds.tipo_cds = 'T') group by a.compania, a.factura) f where a.facturar_a in ('E', 'P') and a.estatus <> 'A' and a.compania = b.compania(+) and a.codigo = b.factura(+) and a.compania = c.compania(+) and a.codigo = c.fac_codigo(+) and a.compania = h.compania(+) and a.codigo = h.fac_codigo(+) and a.compania = d.compania(+) and a.codigo = d.fac_codigo(+) and a.cod_empresa = e.codigo(+) and a.compania = f.compania(+) and a.codigo = f.factura(+) union select 'INF' tipo, e.grupo_empresa, a.compania, 'P' ref_type, a.pac_id ref_code, '0' doc_id, '0' doc_no, to_char(a.fecha_ingreso, 'dd/mm/yyyy') fecha, a.fecha_ingreso, a.pac_id, a.secuencia, a.aseguradora empresa, '0' aplica_a, 'A' grupo_empresa_desc_aplica, ' ',  to_number (get_sec_comp_param (a.compania, 'TP_CLIENTE_PAC')) refer_type, a.pac_id refer_id, (select   p.primer_nombre || decode (p.segundo_nombre, null, '', ' ' || p.segundo_nombre) || decode (p.primer_apellido, null, '', ' ' || p.primer_apellido) || decode (p.segundo_apellido, null, '', ' ' || p.segundo_apellido) || decode (p.sexo, 'F', decode (p.apellido_de_casada, null, '', ' ' || p.apellido_de_casada)) from   tbl_adm_paciente p where p.pac_id = a.pac_id) nombre_cliente, nvl(c.monto, 0) total_bruto, 0 descuento, 0 ajuste, nvl(c.monto_tercero, 0) monto_centro_tercero, nvl(c.monto, 0)-nvl(c.monto_tercero, 0) total_neto, nvl((select descripcion from tbl_adm_grupo_empresa ge where ge.codigo = e.grupo_empresa), '') grupo_empresa_desc, nvl((select descripcion from tbl_adm_tipo_empresa ge where ge.codigo = e.tipo_empresa), '') tipo_empresa_desc, nvl(e.nombre, '') aseguradora_desc, 0 ajuste_centro_iii, nvl((select sum(monto) from tbl_cja_transaccion_pago tp, tbl_cja_detalle_pago dp where tp.codigo = dp.codigo_transaccion and tp.compania = dp.compania and tp.anio = dp.tran_anio and dp.compania = a.compania and dp.anulada = 'N' and dp.admi_secuencia = a.secuencia and tp.pac_id = a.pac_id), 0) pagado, (select adm_type from tbl_adm_categoria_admision ca where ca.codigo = a.categoria) adm_type from tbl_adm_admision a, tbl_adm_empresa e, (select dt.compania, dt.fac_secuencia admision, dt.pac_id, sum(cantidad*decode(tipo_transaccion, 'D', -monto, monto)) monto, sum(decode(cds.tipo_cds, 'T', cantidad * decode(tipo_transaccion, 'D', -monto, monto), 0)) monto_tercero from tbl_fac_detalle_transaccion dt, tbl_cds_centro_servicio cds where dt.centro_servicio = cds.codigo group by dt.compania, dt.fac_secuencia, dt.pac_id) c where a.aseguradora = e.codigo(+) and a.compania = c.compania(+) and a.pac_id = c.pac_id(+) and a.secuencia = c.admision(+) and not exists (select null from tbl_Fac_factura f where f.estatus != 'A' and f.pac_id = a.pac_id and f.admi_secuencia = a.secuencia)) a where compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	if(!client_name.equals("")){
		sbSql.append(" and nombre_cliente like '%");
		sbSql.append(client_name);
		sbSql.append("%'");
	}
	if(!fecha_desde.equals("")){
		sbSql.append(" and trunc(doc_date) >= to_date('");
		sbSql.append(fecha_desde);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!fecha_hasta.equals("")){
		sbSql.append(" and trunc(doc_date) <= to_date('");
		sbSql.append(fecha_hasta);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!no_factura.equals("")){
		sbSql.append(" and doc_id = '");
		sbSql.append(no_factura);
		sbSql.append("'");
	}	
	if(!grupo_empresa.equals("")){
		sbSql.append(" and grupo_empresa = ");
		sbSql.append(grupo_empresa);
	}	
	if(!empresa.equals("")){
		sbSql.append(" and empresa = ");
		sbSql.append(empresa);
	}
	if(!categoria.equals("")){
		sbSql.append(" and a.adm_type = '");
		sbSql.append(categoria);
		sbSql.append("'");
	}	
	if(!ref_type.equals("")){
		sbSql.append(" and a.ref_type = '");
		sbSql.append(ref_type);
		sbSql.append("'");
	}

	sbSql.append(" order by tipo, adm_type, aseguradora_desc, pac_id, admision");

  sbSqlAll.append("select * from (select rownum as rn, a.* from (");
	sbSqlAll.append(sbSql.toString());
	sbSqlAll.append(") a) where rn between ");
	sbSqlAll.append(previousVal);
	sbSqlAll.append(" and ");
	sbSqlAll.append(nextVal);
  if(request.getParameter("fecha_desde")!=null){
	al = SQLMgr.getDataList(sbSqlAll.toString());
  rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql.toString()+") z");
	sbSqlAll = new StringBuffer();
	sbSqlAll.append("select tipo, adm_type_desc, sum(total_bruto) total_bruto, sum(descuento) descuento, sum(ajuste) ajuste, sum(monto_centro_tercero) monto_centro_tercero, sum(total_neto) total_neto, sum(ajuste_centro_iii) ajuste_centro_iii, sum(pagado) pagado from (");
	sbSqlAll.append(sbSql.toString());
	sbSqlAll.append(") group by tipo, adm_type_desc");
	alT = SQLMgr.getDataList(sbSqlAll.toString());
	for(int i = 0; i<alT.size();i++){
		CommonDataObject ct = (CommonDataObject) alT.get(i);
		htT.put(ct.getColValue("tipo")+"_"+ct.getColValue("adm_type_desc"), ct);
	}
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

function showReport(tipo){
	var fDate 			= document.search01.fecha_desde.value||'';
	var tDate 			= document.search01.fecha_hasta.value||'';
	var client_name 		= document.search01.client_name.value||'';
	var no_factura 			= document.search01.no_factura.value||'';
	var grupo_empresa 			= document.search01.grupo_empresa.value||'';
	var empresa 			= document.search01.empresa.value||'';
	var categoria 			= document.search01.categoria.value||'';
	var ref_type 			= document.search01.ref_type.value||'';
	if(tipo=='D') abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=cxc/rpt_cxc_saldo_x_admision.rptdesign&fDesde='+fDate+'&fHasta='+tDate+'&clienteParam='+client_name+'&noFactParam='+no_factura+'&tipoEmpParam='+grupo_empresa+'&empresaParam='+empresa+'&catParam='+categoria+'&facturarAParam='+ref_type);
	else if(tipo=='R') abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=cxc/rpt_cxc_saldo_x_adm_res.rptdesign&fDesde='+fDate+'&fHasta='+tDate+'&clienteParam='+client_name+'&noFactParam='+no_factura+'&tipoEmpParam='+grupo_empresa+'&empresaParam='+empresa+'&catParam='+categoria+'&facturarAParam='+ref_type);
	else if(tipo=='A') abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=cxc/rpt_cxc_saldo_x_admision_res.rptdesign&fDesde='+fDate+'&fHasta='+tDate+'&clienteParam='+client_name+'&noFactParam='+no_factura+'&tipoEmpParam='+grupo_empresa+'&empresaParam='+empresa+'&catParam='+categoria+'&facturarAParam='+ref_type);
}

function selEmpresa()
{
abrir_ventana2('../common/search_empresa.jsp?fp=informe_ingresos');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value=""></jsp:param>
</jsp:include>
<table align="center" width="70%" cellpadding="1" cellspacing="0">
  <tr>
    <td><!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
      <table width="100%" cellpadding="0" cellspacing="0">
          <%
					  fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
          <%=fb.formStart()%> 
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> 
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%> 
					<%=fb.hidden("fg",fg)%>
        <tr class="TextFilter">
          <td width="20%">Fecha:</td><td width="80%"> 
          <jsp:include page="../common/calendar.jsp" flush="true">
          <jsp:param name="noOfDateTBox" value="2" />
          <jsp:param name="clearOption" value="true" />
          <jsp:param name="nameOfTBox1" value="fecha_desde" />
          <jsp:param name="valueOfTBox1" value="<%=fecha_desde%>" />
          <jsp:param name="nameOfTBox2" value="fecha_hasta" />
          <jsp:param name="valueOfTBox2" value="<%=fecha_hasta%>" />
          </jsp:include>
					</td>
          </tr>
					<tr class="TextFilter"><td>
					Cliente:</td><td>
					<%=fb.textBox("client_name",client_name,false,false,false,40,"Text10",null,"")%> 
					</td>
          </tr>
          <tr class="TextFilter"><td>
					No. Factura:</td><td>
					<%=fb.textBox("no_factura",no_factura,false,false,false,12,"Text10",null,"")%> 
					</td>
          </tr>
					<tr class="TextFilter"><td>
					Tipo Empresa:</td><td>
					<%=fb.select(ConMgr.getConnection(),"select codigo, '['||codigo||'] '||descripcion from tbl_adm_grupo_empresa order by codigo","grupo_empresa",grupo_empresa,false,false,0,"text10",null,"", "", "S")%>
					</td>
          </tr>
					<tr class="TextFilter"><td>
					Empresa:</td><td>
					<%=fb.textBox("empresa",empresa,false,false,false,5)%>
					<%=fb.textBox("empresa_desc",empresa_desc,false,false,false,25)%>
					<%=fb.button("addempresa","...",true,false,null,null,"onClick=\"javascript:selEmpresa()\"","Seleccionar empresa")%>
					</td>
          </tr>
					<tr class="TextFilter"><td>
					Categor&iacute;a:</td><td>
					<%=fb.select(ConMgr.getConnection(),"select distinct adm_type,decode(adm_type,'I','INGRESOS - IP','INGRESOS - OP') categoria from tbl_adm_categoria_admision order by 1","categoria",categoria,"T")%>
					</td>
          </tr>
					<tr class="TextFilter"><td>
					Facturar a:</td><td>
					<%=fb.select("ref_type","E=EMPRESA,P=PACIENTE",ref_type,false,false,0,"Text10",null,null,null,"T")%>
					<!--Esconder Header-->
					<%//=fb.checkbox("pCtrlHeader","")%>
          </td>
          </tr>
					<%=fb.formEnd()%> 
					<tr>
							<td colspan="2" align="center"><authtype type='0'><a href="javascript:showReport('D')" class="Link00">[ Reporte Detallado]</a>&nbsp;&nbsp;<a href="javascript:showReport('R')" class="Link00">[ Reporte Resumido]</a>&nbsp;&nbsp;<a href="javascript:showReport('A')" class="Link00">[ Reporte Resumido por Aseguradora]</a></authtype></td>
						</tr>
					</table>
      <!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
    </td>
  </tr>
</table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
