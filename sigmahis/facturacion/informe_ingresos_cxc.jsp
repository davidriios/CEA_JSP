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
String categoria = request.getParameter("categoria");
String tipoAdm = request.getParameter("tipoAdm");
String empresa = request.getParameter("empresa");
String empresa_desc = request.getParameter("empresa_desc");

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
	
	if(request.getParameter("client_name")!=null){
	
  sbSql.append("select a.* from (select 'IF' tipo, e.grupo_empresa, a.compania, a.facturar_a ref_type, decode (a.facturar_a, 'P', a.pac_id, 'E', a.cod_empresa) ref_code, a.codigo doc_id, a.codigo doc_no, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.fecha doc_date, a.pac_id, a.admi_secuencia admision, a.cod_empresa empresa, a.codigo aplica_a, 'F' grupo_empresa_desc_aplica, a.comentario descripcion,  decode ( a.facturar_a, 'P', to_number (get_sec_comp_param (a.compania, 'TP_CLIENTE_PAC')), 'E', to_number (get_sec_comp_param (a.compania, 'TP_CLIENTE_EMP'))) refer_type, decode (a.facturar_a, 'P', a.pac_id, 'E', a.cod_empresa) refer_id, (case when a.facturar_a = 'P' then (select nombre_paciente from vw_adm_paciente p where p.pac_id = a.pac_id) else a.nombre_cliente end) nombre_cliente, (a.grang_total+nvl(a.monto_descuento, 0)+nvl(monto_descuento2, 0)) total_bruto, -(nvl(a.monto_descuento, 0)+nvl(monto_descuento2, 0)) descuento, nvl (b.ajuste, 0) ajuste, nvl (c.monto, 0) monto_centro_tercero, (a.grang_total+nvl(b.ajuste, 0)-nvl (c.monto, 0)+nvl(f.ajuste_centro_iii, 0)) total_neto, nvl((select descripcion from tbl_adm_grupo_empresa ge where ge.codigo = e.grupo_empresa), '') grupo_empresa_desc, nvl((select descripcion from tbl_adm_tipo_empresa ge where ge.codigo = e.tipo_empresa), '') tipo_empresa_desc, nvl(e.nombre, '') aseguradora_desc, nvl(f.ajuste_centro_iii, 0) ajuste_centro_iii, a.categoria_admi as categoria , a.adm_type as tipoAdm from tbl_fac_factura a, (select a.compania, a.factura, nvl(sum(decode(a.lado_mov, 'D', a.monto, 0)), 0)-nvl(sum(decode(a.lado_mov, 'C', a.monto, 0)), 0) ajuste from vw_con_adjustment_gral a where a.tipo_ajuste not in (select codigo from tbl_fac_tipo_ajuste where compania = a.compania and group_type = 'E') and not exists (select null from tbl_cds_centro_servicio cds where cds.codigo = a.centro and cds.tipo_cds = 'T') group by a.compania, a.factura) b, (select compania, fac_codigo, sum (monto) monto from tbl_fac_detalle_factura df where exists (select null from   tbl_cds_centro_servicio cds where   cds.codigo = df.centro_servicio and cds.tipo_cds = 'T') group by compania, fac_codigo) c, tbl_adm_empresa e, (select a.compania, a.factura, nvl(sum(decode(a.lado_mov, 'D', a.monto, 0)), 0) - nvl(sum(decode(a.lado_mov, 'C', a.monto, 0)), 0) ajuste_centro_iii from vw_con_adjustment_gral a where a.tipo_ajuste not in (select codigo from tbl_fac_tipo_ajuste where compania = a.compania and group_type = 'E') and exists (select null from tbl_cds_centro_servicio cds where cds.codigo = a.centro and cds.tipo_cds = 'T') group by a.compania, a.factura) f where a.facturar_a in ('E', 'P') and a.estatus <> 'A' and a.compania = b.compania(+) and a.codigo = b.factura(+) and a.compania = c.compania(+) and a.codigo = c.fac_codigo(+)  and a.cod_empresa = e.codigo(+) and a.compania = f.compania(+) and a.codigo = f.factura(+)");
	if(!fecha_desde.equals("")){
		sbSql.append(" and trunc(a.fecha) >= to_date('");
		sbSql.append(fecha_desde);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!fecha_hasta.equals("")){
		sbSql.append(" and trunc(a.fecha) <= to_date('");
		sbSql.append(fecha_hasta);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	sbSql.append(" union select 'INF' tipo, e.grupo_empresa, a.compania, 'P' ref_type, a.pac_id ref_code, '0' doc_id, '0' doc_no, to_char(a.fecha_ingreso, 'dd/mm/yyyy') fecha, a.fecha_ingreso, a.pac_id, a.secuencia, a.aseguradora empresa, '0' aplica_a, 'A' grupo_empresa_desc_aplica, ' ',  to_number (get_sec_comp_param (a.compania, 'TP_CLIENTE_PAC')) refer_type, a.pac_id refer_id, (select  nombre_paciente from  vw_adm_paciente p where p.pac_id = a.pac_id) nombre_cliente, nvl(c.monto, 0) total_bruto, 0 descuento, 0 ajuste, nvl(c.monto_tercero, 0) monto_centro_tercero, nvl(c.monto, 0)-nvl(c.monto_tercero, 0) total_neto, nvl((select descripcion from tbl_adm_grupo_empresa ge where ge.codigo = e.grupo_empresa), '') grupo_empresa_desc, nvl((select descripcion from tbl_adm_tipo_empresa ge where ge.codigo = e.tipo_empresa), '') tipo_empresa_desc, nvl(e.nombre, '') aseguradora_desc, 0 ajuste_centro_iii , a.categoria as categoria, a.adm_type as tipoAdm from tbl_adm_admision a, tbl_adm_empresa e, (select dt.compania, dt.fac_secuencia admision, dt.pac_id, sum(cantidad*decode(tipo_transaccion, 'D', -monto, monto)) monto, sum(decode(cds.tipo_cds, 'T', cantidad * decode(tipo_transaccion, 'D', -monto, monto), 0)) monto_tercero from tbl_fac_detalle_transaccion dt, tbl_cds_centro_servicio cds where dt.centro_servicio = cds.codigo ");
	if(!fecha_desde.equals("")){
		sbSql.append(" and trunc(dt.fecha_creacion) >= to_date('");
		sbSql.append(fecha_desde);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!fecha_hasta.equals("")){
		sbSql.append(" and trunc(dt.fecha_creacion) <= to_date('");
		sbSql.append(fecha_hasta);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	sbSql.append(" group by dt.compania, dt.fac_secuencia, dt.pac_id) c where a.aseguradora = e.codigo(+) and a.compania = c.compania(+) and a.pac_id = c.pac_id(+) and a.secuencia = c.admision(+) and not exists (select null from tbl_Fac_factura f where f.estatus != 'A' and f.pac_id = a.pac_id and f.admi_secuencia = a.secuencia)) a where compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	if(!client_name.equals("")){
		sbSql.append(" and nombre_cliente like '%");
		sbSql.append(client_name);
		sbSql.append("%'");
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
			sbSql.append(" and categoria = ");
			sbSql.append(categoria);
	}
	if(!tipoAdm.equals("")){
		sbSql.append(" and tipoAdm = '");
		sbSql.append(tipoAdm);
		sbSql.append("'");
	}
	
	sbSql.append(" order by tipo, grupo_empresa, pac_id, admision");

  sbSqlAll.append("select * from (select rownum as rn, a.* from (");
	sbSqlAll.append(sbSql.toString());
	sbSqlAll.append(") a) where rn between ");
	sbSqlAll.append(previousVal);
	sbSqlAll.append(" and ");
	sbSqlAll.append(nextVal);
  al = SQLMgr.getDataList(sbSqlAll.toString());
  rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql.toString()+") z");
	sbSqlAll = new StringBuffer();
	sbSqlAll.append("select tipo, grupo_empresa_desc, sum(total_bruto) total_bruto, sum(descuento) descuento, sum(ajuste) ajuste, sum(monto_centro_tercero) monto_centro_tercero, sum(total_neto) total_neto, sum(ajuste_centro_iii) ajuste_centro_iii from (");
	sbSqlAll.append(sbSql.toString());
	sbSqlAll.append(") group by tipo, grupo_empresa_desc, categoria, tipoAdm");
	alT = SQLMgr.getDataList(sbSqlAll.toString());
	for(int i = 0; i<alT.size();i++){
		CommonDataObject ct = (CommonDataObject) alT.get(i);
		htT.put(ct.getColValue("tipo")+"_"+ct.getColValue("grupo_empresa_desc"), ct);
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

function showReport(){
	var fDate 			= document.search01.fecha_desde.value;
	var tDate 			= document.search01.fecha_hasta.value;
	var client_name 		= document.search01.client_name.value;
	var no_factura 			= document.search01.no_factura.value;
	var grupo_empresa 			= document.search01.grupo_empresa.value;
	var empresa 			= document.search01.empresa.value;
	var categoria 			= document.search01.categoria.value || 'ALL';
	var tipoAdm 			= document.search01.tipoAdm.value || 'ALL';
	abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=facturacion/informe_ingreso_cxc.rptdesign&pacienteParam='+client_name+'&facturaParam='+no_factura+'&fechaDesdeParam='+fDate+'&fechaHastaParam='+tDate+'&grupoParam='+grupo_empresa+'&empresaParam='+empresa+'&categoria='+categoria+'&tipo_adm='+tipoAdm);
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
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td><!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
      <table width="100%" cellpadding="0" cellspacing="0">
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
					Tipo Empresa:
					<%=fb.select(ConMgr.getConnection(),"select codigo, '['||codigo||'] '||descripcion from tbl_adm_grupo_empresa order by codigo","grupo_empresa",grupo_empresa,false,false,0,"text10",null,"", "", "S")%>
					<br>
					Empresa:
					<%=fb.textBox("empresa",empresa,false,false,false,5)%>
					<%=fb.textBox("empresa_desc",empresa_desc,false,false,false,25)%>
					<%=fb.button("addempresa","...",true,false,null,null,"onClick=\"javascript:selEmpresa()\"","Seleccionar empresa")%>
					&nbsp;&nbsp; Tipo de Admisión:	
					<%=fb.select(ConMgr.getConnection(), "Select codigo, descripcion From tbl_adm_categoria_admision order by 1","categoria",categoria,false,false,0,"text10",null,"","","S")%>
                                        &nbsp;&nbsp; Categoria :	
				 	 <%=fb.select(ConMgr.getConnection(),"select distinct adm_type,decode(adm_type,'I','INGRESOS - IP','INGRESOS - OP') tipoAdm from tbl_adm_categoria_admision order by 1","tipoAdm",tipoAdm,false,false,0,"text10",null,"","","S")%>
				   <%=fb.submit("go","Ir")%> 
					<!--Esconder Header-->
					<%//=fb.checkbox("pCtrlHeader","")%>
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
					<%=fb.hidden("grupo_empresa",grupo_empresa)%>
					<%=fb.hidden("empresa",empresa)%>
					<%=fb.hidden("empresa_desc",empresa_desc)%>
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
					<%=fb.hidden("grupo_empresa",grupo_empresa)%>
					<%=fb.hidden("empresa",empresa)%>
					<%=fb.hidden("empresa_desc",empresa_desc)%>
          <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
          <%=fb.formEnd()%> </tr>
      </table></td>
  </tr>
	<tr>
		<td align="right"><authtype type='0'><a href="javascript:showReport()" class="Link00">[ Reporte ]</a></authtype></td>
	</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableLeftBorder TableRightBorder"><!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
      <table align="center" width="100%" cellpadding="0" cellspacing="1">
        <tr class="TextHeader" align="center">
					<td width="7%">No. Factura</td>
					<td width="6%">Fecha</td>
					<td width="7%">Pac.Id/Admisi&oacute;n</td>
					<td width="23%">Nombre de Cliente</td>
					<td width="15%">Aseguradora</td>
					<td width="7%">Ingreo Bruto</td>
					<td width="7%">Descuento</td>
					<td width="7%">Ajustes</td>
					<td width="7%">Centros Terceros</td>
					<td width="7%">Ajus./Desc. Centros III</td>
					<td width="7%">Ingreso Neto</td>
				</tr>
				<%
				String grupo_empresa_desc = "";
				String tipo = "", key = "";
				double total_bruto = 0.00, descuento = 0.00, ajuste = 0.00, monto_centro_tercero = 0.00, total_neto = 0.00, ajuste_centro_iii = 0.00;
				double Total_Bruto = 0.00, Descuento = 0.00, Ajuste = 0.00, Monto_Centro_Tercero = 0.00, Total_Neto = 0.00, Ajuste_Centro_III = 0.00;
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
       <%
					if(i!=0 && !key.equals(cdo.getColValue("tipo")+"_"+cdo.getColValue("grupo_empresa_desc"))){
						if(htT.containsKey(key)){
						CommonDataObject ct = (CommonDataObject) htT.get(key);
				%>
				<tr class="Text10Bold">
          <td colspan="5" align="right">Total:</td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(ct.getColValue("total_bruto"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(ct.getColValue("descuento"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(ct.getColValue("ajuste"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(ct.getColValue("monto_centro_tercero"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(ct.getColValue("ajuste_centro_iii"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(ct.getColValue("total_neto"))%></td>
        </tr>
				<%
					total_bruto += Double.parseDouble(ct.getColValue("total_bruto"));
					descuento += Double.parseDouble(ct.getColValue("descuento"));
					ajuste += Double.parseDouble(ct.getColValue("ajuste"));
					monto_centro_tercero += Double.parseDouble(ct.getColValue("monto_centro_tercero"));
					ajuste_centro_iii += Double.parseDouble(ct.getColValue("ajuste_centro_iii"));
					total_neto += Double.parseDouble(ct.getColValue("total_neto"));
					
					Total_Bruto += Double.parseDouble(ct.getColValue("total_bruto"));
					Descuento += Double.parseDouble(ct.getColValue("descuento"));
					Ajuste += Double.parseDouble(ct.getColValue("ajuste"));
					Monto_Centro_Tercero += Double.parseDouble(ct.getColValue("monto_centro_tercero"));
					Ajuste_Centro_III += Double.parseDouble(ct.getColValue("ajuste_centro_iii"));
					Total_Neto += Double.parseDouble(ct.getColValue("total_neto"));
					}
				}
				%>
				<%if(!tipo.equals(cdo.getColValue("tipo"))){%>
				<%if(i!=0){%>
				<tr class="Text10Bold">
          <td colspan="5" align="right">TOTAL <%=(tipo.equals("IF")?"INGRESOS FACTURADOS" : "INGRESOS NO FACTURADOS")%>:</td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(total_bruto)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(descuento)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(ajuste)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(monto_centro_tercero)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(ajuste_centro_iii)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(total_neto)%></td>
        </tr>
				<%
					total_bruto = 0.00;
					descuento = 0.00;
					ajuste = 0.00;
					monto_centro_tercero = 0.00;
					ajuste_centro_iii = 0.00;
					total_neto = 0.00;
				}
				%>
        <tr class="">
          <td colspan="11" align="center"><b><%=(cdo.getColValue("tipo").equals("IF")?"INGRESOS FACTURADOS" : "INGRESOS NO FACTURADOS")%></td>
				</tr>
				<%
				grupo_empresa_desc="";
				}
				if(!grupo_empresa_desc.equals(cdo.getColValue("grupo_empresa_desc"))){%>
        <tr class="Text10Bold">
          <td colspan="11"><%=cdo.getColValue("grupo_empresa_desc")%></td>
				</tr>
				<%}
				
				%>
        <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
          <td align="center"><%=cdo.getColValue("doc_id")%></td>
          <td align="center"><%=cdo.getColValue("fecha")%></td>
          <td align="center"><%=cdo.getColValue("pac_id")%>-<%=cdo.getColValue("admision")%></td>
          <td><%=cdo.getColValue("nombre_cliente")%></td>
          <td><%=cdo.getColValue("aseguradora_desc")%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("total_bruto"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("descuento"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ajuste"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_centro_tercero"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ajuste_centro_iii"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("total_neto"))%></td>
        </tr>
        <%
					key = cdo.getColValue("tipo")+"_"+cdo.getColValue("grupo_empresa_desc");
					grupo_empresa_desc = cdo.getColValue("grupo_empresa_desc");
					tipo = cdo.getColValue("tipo");
				}
				%>
        <%
					if(htT.containsKey(key)){
						if(htT.containsKey(key)){
						CommonDataObject ct = (CommonDataObject) htT.get(key);
				%>
				<tr class="Text10Bold">
          <td colspan="5" align="right">Total:</td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(ct.getColValue("total_bruto"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(ct.getColValue("descuento"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(ct.getColValue("ajuste"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(ct.getColValue("monto_centro_tercero"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(ct.getColValue("ajuste_centro_iii"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(ct.getColValue("total_neto"))%></td>
        </tr>
				<%
					total_bruto += Double.parseDouble(ct.getColValue("total_bruto"));
					descuento += Double.parseDouble(ct.getColValue("descuento"));
					ajuste += Double.parseDouble(ct.getColValue("ajuste"));
					monto_centro_tercero += Double.parseDouble(ct.getColValue("monto_centro_tercero"));
					ajuste_centro_iii += Double.parseDouble(ct.getColValue("ajuste_centro_iii"));
					total_neto += Double.parseDouble(ct.getColValue("total_neto"));

					Total_Bruto += Double.parseDouble(ct.getColValue("total_bruto"));
					Descuento += Double.parseDouble(ct.getColValue("descuento"));
					Ajuste += Double.parseDouble(ct.getColValue("ajuste"));
					Monto_Centro_Tercero += Double.parseDouble(ct.getColValue("monto_centro_tercero"));
					Ajuste_Centro_III += Double.parseDouble(ct.getColValue("ajuste_centro_iii"));
					Total_Neto += Double.parseDouble(ct.getColValue("total_neto"));
					}%>
				<%if(al.size()!=0){%>
				<tr class="Text10Bold">
          <td colspan="5" align="right">TOTAL <%=(tipo.equals("IF")?"INGRESOS FACTURADOS" : "INGRESOS NO FACTURADOS")%>:</td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(total_bruto)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(descuento)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(ajuste)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(monto_centro_tercero)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(ajuste_centro_iii)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(total_neto)%></td>
        </tr>
				<%}%>
					<%
					}%>
				<tr class="Text10Bold">
          <td colspan="5" align="right">TOTAL INGRESOS:</td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(Total_Bruto)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(Descuento)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(Ajuste)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(Monto_Centro_Tercero)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(Ajuste_Centro_III)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(Total_Neto)%></td>
        </tr>
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
					<%=fb.hidden("grupo_empresa",grupo_empresa)%>
					<%=fb.hidden("empresa",empresa)%>
					<%=fb.hidden("empresa_desc",empresa_desc)%>
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
					<%=fb.hidden("grupo_empresa",grupo_empresa)%>
					<%=fb.hidden("empresa",empresa)%>
					<%=fb.hidden("empresa_desc",empresa_desc)%>
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
