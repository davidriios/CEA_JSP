<%@ page errorPage="../error.jsp"%>
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
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fHasta = request.getParameter("fHasta");
String fp = request.getParameter("fp");
String fDesde = request.getParameter("fDesde");
String cFecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
String diferencia = request.getParameter("diferencia");

int iconHeight = 48;
int iconWidth = 48;
if (fHasta == null) fHasta = cFecha;
if (fp == null) fp = "";
if (fDesde == null) fDesde = cFecha;
if (diferencia == null) diferencia = "";


if (request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";

	if (request.getParameter("searchQuery") != null)
	{
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	String aseguradora = request.getParameter("aseguradora");
	String aseguradoraDesc = request.getParameter("aseguradoraDesc");
	String pacId = request.getParameter("pacId");
	String nombre = request.getParameter("nombre");
	String categoria = request.getParameter("categoria");
	String noAdm = request.getParameter("noAdm");
	String tipoAdm = request.getParameter("tipoAdm");
	
	sbSql = new StringBuffer();
	sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append((String) session.getAttribute("_companyId"));	 	
	sbSql.append(", 'INV_USA_COSTO_CIERRE_MES'), 'N') usa_costo from dual");	
	CommonDataObject cd = new CommonDataObject();
	cd = SQLMgr.getData(sbSql.toString());  
	
	sbSql = new StringBuffer();
	 
	if (aseguradora == null) aseguradora = "";
	if (aseguradoraDesc == null) aseguradoraDesc = "";
	if (pacId == null) pacId = "";
	if (nombre == null) nombre = "";
	if (categoria == null) categoria = "";
	if (noAdm ==null)noAdm="";
	if (tipoAdm == null) tipoAdm = "";
	if (!aseguradora.trim().equals("")) { sbFilter.append(" and exists (select null from tbl_adm_beneficios_x_admision ba where ba.pac_id = a.pac_id and ba.admision = a.secuencia and ba.estado = 'A' and empresa = "); sbFilter.append(aseguradora.toUpperCase()); sbFilter.append(")"); }
	if(!fDesde.trim().equals("")){ sbFilter.append(" and f.fecha >= to_date('"); sbFilter.append(fDesde); sbFilter.append("','dd/mm/yyyy')"); }
	if(!fHasta.trim().equals("")){sbFilter.append(" and f.fecha <= to_date('"); sbFilter.append(fHasta); sbFilter.append("','dd/mm/yyyy')");}
	if (!pacId.trim().equals("")) { sbFilter.append(" and f.pac_id = "); sbFilter.append(pacId);}
	if (!noAdm.trim().equals("")) { sbFilter.append(" and f.admi_secuencia = "); sbFilter.append(noAdm);}
    
    if (!categoria.trim().equals("")) {
       sbFilter.append(" and a.categoria = ");       
       sbFilter.append(categoria);       
    }
	if (!tipoAdm.trim().equals("")) { sbFilter.append(" and a.tipo_admision = "); sbFilter.append(tipoAdm); }
		if (!diferencia.trim().equals("")){
		sbSql.append(" select * from (");
		}
		sbSql.append("select compania, nombre, pac_id, secuencia, poliza, empresa, sum (ajustes_pac) ajustes_pac, sum (pagos_pac) pagos_pac, sum (ajustes_emp) ajustes_emp, sum (pagos_emp) pagos_emp, nvl((select sum (decode (b.tipo_transaccion, 'D', -1 * b.cantidad, b.cantidad) * (b.monto + nvl (b.recargo, 0))) monto from tbl_fac_detalle_transaccion b where b.pac_id = a.pac_id and b.fac_secuencia = a.secuencia and b.compania = a.compania),0) cargos, sum(monto_fact_pac) monto_fact_pac, sum(monto_desc_pac) monto_desc_pac, sum(monto_fact_emp) monto_fact_emp, sum(monto_desc_emp) monto_desc_emp, cat_desc ,nvl((select   sum(fdt.monto) as monto from tbl_fac_detalle_factura fdt, tbl_fac_factura f where fdt.fac_codigo=f.codigo and fdt.compania=a.compania and f.pac_id =a.pac_id and f.admi_secuencia =a.secuencia and nvl(fdt.imprimir_sino,'X') = 'N' and f.estatus <> 'A' ),0) as paquete,nvl((select sum (decode (b.tipo_transaccion, 'D', -1 * b.cantidad, b.cantidad) * decode(nvl(b.inv_articulo,0),0,nvl(b.costo_art,0), decode('");
		sbSql.append(cd.getColValue("usa_costo"));		
		sbSql.append("','S',getCostoComprob(b.compania,b.inv_almacen,b.inv_articulo, to_char(b.fecha_creacion,'mm'),to_char(b.fecha_creacion,'yyyy'), nvl(b.costo_art,0),'");
		sbSql.append(cd.getColValue("usa_costo"));	
		sbSql.append("' ),nvl(b.costo_art,0)))) costo from tbl_fac_detalle_transaccion b where b.pac_id = a.pac_id and b.fac_secuencia = a.secuencia and b.compania = a.compania),0) as costo,nvl((select nvl(total,0) from tbl_fac_cotizacion co where exists (select null from tbl_fac_detalle_transaccion b where b.pac_id = a.pac_id and b.fac_secuencia = a.secuencia and b.compania = a.compania and co.id =b.ref_id and b.ref_type='PAQ' ) ),0) as  costo_paq from (select a.compania, pp.nombre_paciente nombre, a.pac_id, a.secuencia, nvl ((select sum ( decode (ad.lado_mov, 'D', ad.monto, 'C', -1 * monto)) from vw_con_adjustment_gral ad, tbl_fac_tipo_ajuste ta where ad.tipo_doc = 'F' and ta.group_type not in ('D', 'F') and ta.compania = ad.compania and ta.codigo = ad.tipo_ajuste and f.estatus <> 'A' and f.compania = ad.compania and f.codigo = ad.factura and f.pac_id = a.pac_id and f.admi_secuencia = a.secuencia and f.facturar_a = 'P'), 0) ajustes_pac, nvl ((select sum (nvl (p.monto, 0)) cobrado from tbl_cja_detalle_pago p, tbl_cja_transaccion_pago t where     t.rec_status <> 'I' and p.cod_rem is null and p.tran_anio = t.anio and p.compania = t.compania and p.codigo_transaccion = t.codigo and f.compania = p.compania and f.codigo = p.fac_codigo and f.facturar_a = 'P'), 0) pagos_pac, nvl ((select sum ( decode (ad.lado_mov, 'D', ad.monto, 'C', -1 * monto)) from vw_con_adjustment_gral ad, tbl_fac_tipo_ajuste ta where ad.tipo_doc = 'F' and ta.group_type not in ('D', 'F') and ta.compania = ad.compania and ta.codigo = ad.tipo_ajuste and f.estatus <> 'A' and f.compania = ad.compania and f.codigo = ad.factura and f.pac_id = a.pac_id and f.admi_secuencia = a.secuencia and f.facturar_a = 'E'), 0) ajustes_emp, nvl ((select sum (nvl (p.monto, 0)) cobrado from tbl_cja_detalle_pago p, tbl_cja_transaccion_pago t where t.rec_status <> 'I' and p.cod_rem is null and p.tran_anio = t.anio and p.compania = t.compania and p.codigo_transaccion = t.codigo and f.compania = p.compania and f.codigo = p.fac_codigo and f.facturar_a = 'E'), 0) pagos_emp, decode(f.facturar_a, 'P', f.grang_total, 0) monto_fact_pac, decode(f.facturar_a,'P', nvl(f.monto_descuento,0)+nvl(f.monto_descuento2,0)+nvl(f.monto_descuento_hon,0),0) monto_desc_pac, decode(f.facturar_a, 'E', f.grang_total, 0) monto_fact_emp, decode(f.facturar_a,'E',nvl(f.monto_descuento,0)+nvl(f.monto_descuento2,0)+nvl(f.monto_descuento_hon,0),0) monto_desc_emp, nvl((select poliza from tbl_adm_beneficios_x_admision ba where ba.pac_id = a.pac_id and ba.admision = a.secuencia and ba.estado = 'A' and prioridad = 1 and rownum = 1), '') poliza, nvl((select (select nombre from tbl_adm_empresa e where e.codigo = ba.empresa) || ' - ' || ba.empresa from tbl_adm_beneficios_x_admision ba where ba.pac_id = a.pac_id and ba.admision = a.secuencia and ba.estado = 'A' and ba.prioridad = 1 and rownum = 1), '') empresa , cat.descripcion||' - '||(select descripcion from tbl_adm_tipo_admision_cia where categoria = a.categoria and codigo = a.tipo_admision) as cat_desc from vw_adm_paciente pp, tbl_adm_admision a, tbl_fac_factura f, tbl_adm_categoria_admision cat where pp.pac_id = a.pac_id and f.estatus != 'A' and f.compania = a.compania and f.pac_id = a.pac_id and f.admi_secuencia = a.secuencia and a.categoria = cat.codigo and f.compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(sbFilter);
		sbSql.append(") a ");
		/*if (!diferencia.trim().equals("")){
		sbSql.append(" where  ");
		}*/		
		sbSql.append("group by compania, nombre, pac_id, secuencia, poliza, empresa, cat_desc");
		
		if (!diferencia.trim().equals("")){
		sbSql.append(") where nvl(costo,0) < ( nvl(monto_fact_pac,0) + nvl(monto_fact_emp,0)) ");
		}	
		sbSql.append(" order by cat_desc, nombre, secuencia ");
		
		
		if(	request.getParameter("beginSearch") != null){
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
		
		rowCount = CmnMgr.getCount("select count(*) from ("+sbSql+")");
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
var sql = "<%=sbSql.toString()%>"
var gTitleAlert = '<%=java.util.ResourceBundle.getBundle("issi").getString("windowTitle")%>';
document.title = 'LISTADO DE RECIBOS - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}

function showReporte()
{
	var fechaIni=document.form0.fDesde.value;
	var fechaFin=document.form0.fHasta.value;
	var aseguradora = document.form0.aseguradora.value || 'ALL' ;
	var aseguradoraDesc = document.form0.aseguradoraDesc.value || 'ALL';
	var pacId = document.form0.pacId.value || 'ALL';
	var categoria = document.form0.categoria.value || 'ALL';
	var tipoAdm = document.form0.tipoAdm.value || 'ALL';
	var noAdm = document.form0.noAdm.value || 'ALL';
	var diferencia = "ALL";
	if(document.form0.diferencia.checked==true) diferencia = "S";
    /*if (!fechaIni || !fechaFin) CBMSG.error("Por favor seleccione un rango de fecha!");
    else*/
    abrir_ventana1('../cellbyteWV/report_container.jsp?reportName=cxc/rpt_costos_vs_facturacion.rptdesign&fDesde='+fechaIni+'&fHasta='+fechaFin+'&aseguradora='+aseguradora+'&pac_id='+pacId+'&aseguradora_desc='+aseguradoraDesc+'&categoria='+categoria+'&noAdm='+noAdm+'&diferencia='+diferencia+'&pCtrlHeader=false&tipoAdm='+tipoAdm+'&usa_costo=<%=cd.getColValue("usa_costo")%>');
}

function showEmpresaList(){abrir_ventana1('../common/search_empresa.jsp?fp=morosidad');}
function showPacienteList(){abrir_ventana1('../common/search_paciente.jsp?fp=morosidad');}

function viewFact(p_facturar_a, pac_id, admision){
	abrir_ventana1('../facturacion/print_factura.jsp?facturar_a='+p_facturar_a+'&compania=<%=(String) session.getAttribute("_companyId")%>&pacId='+pac_id+'&admision='+admision);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CAJA - LISTADO DE RECIBOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("beginSearch","")%>
		<tr class="TextFilter" valign="top">
			
			<td>
				Fecha
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="noOfDateTBox" value="2" />
				<jsp:param name="nameOfTBox1" value="fDesde" />
				<jsp:param name="valueOfTBox1" value="<%=fDesde%>" />
				<jsp:param name="nameOfTBox2" value="fHasta" />
				<jsp:param name="valueOfTBox2" value="<%=fHasta%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				</jsp:include>
			
				Aseguradora
				
				<%=fb.textBox("aseguradora",aseguradora,false,false,false,5,"Text10",null,null)%>
					<%=fb.textBox("aseguradoraDesc",aseguradoraDesc,false,false,true,30,"Text10",null,null)%>
					<%=fb.button("btnAseg","...",true,false,"Text10",null,"onClick=\"javascript:showEmpresaList()\"")%>
			
				Paciente
				
				<%=fb.textBox("pacId",pacId,false,false,false,5,"Text10",null,null)%>
				ADM:<%=fb.textBox("noAdm",noAdm,false,false,false,5,"Text10",null,null)%>
					<%=fb.textBox("nombre",nombre,false,false,true,30,"Text10",null,null)%>
					<%=fb.button("btnPac","...",true,false,"Text10",null,"onClick=\"javascript:showPacienteList()\"")%>
					<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
					Costo menor a Fact:<%=fb.checkbox("diferencia","S",diferencia.equals("S"),false)%>&nbsp;
			</td>
			
		</tr>
        
		<tr class="TextFilter" valign="top">

			<td>
			<cellbytelabel>Categor&iacute;a</cellbytelabel>
			<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, codigo from tbl_adm_categoria_admision","categoria",categoria,false,false,0,"Text10",null,"onChange=\"javascript:loadXML('../xml/itemTipo.xml','tipoAdm','','VALUE_COL','LABEL_COL',this.value,'KEY_COL','T')\"",null,"T")%>
			<cellbytelabel>Tipo Admisi&oacute;n</cellbytelabel>
			<%=fb.select("tipoAdm","","",false,false,0,"Text10",null,null,null,"T")%>
			<script language="javascript">
			loadXML('../xml/itemTipo.xml','tipoAdm','<%=tipoAdm%>','VALUE_COL','LABEL_COL',document.form0.categoria.value,'KEY_COL','T');
			</script>
			</td>

		</tr>


<%=fb.formEnd(true)%>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</td>
</tr>
<tr>
	<td align="right"><authtype type='0'><a href="javascript:showReporte()" class="Link00">[ <cellbytelabel>Imprimir</cellbytelabel> ]</a></authtype></td>
</tr>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
<%=fb.hidden("fHasta",fHasta)%>
<%=fb.hidden("fDesde",fDesde)%>
<%=fb.hidden("aseguradora",aseguradora)%>
<%=fb.hidden("aseguradoraDesc",aseguradoraDesc)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("beginSearch","")%>
<%=fb.hidden("noAdm",noAdm)%>
<%=fb.hidden("diferencia",diferencia)%>
<%=fb.hidden("tipoAdm",tipoAdm)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
<%=fb.hidden("fHasta",fHasta)%>
<%=fb.hidden("fDesde",fDesde)%>
<%=fb.hidden("aseguradora",aseguradora)%>
<%=fb.hidden("aseguradoraDesc",aseguradoraDesc)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("beginSearch","")%>
<%=fb.hidden("noAdm",noAdm)%>
<%=fb.hidden("diferencia",diferencia)%>
<%=fb.hidden("tipoAdm",tipoAdm)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
		<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="list" exclude="10">
<%fb = new FormBean("form01","","");%>
<%=fb.formStart()%>
<%=fb.hidden("index","-1")%>
		<tr class="TextHeader" align="center">
			<td width="10%"><cellbytelabel>Expediente</cellbytelabel></td>
			<td width="11%"><cellbytelabel>Poliza</cellbytelabel></td>
			<td width="21%"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Cargos</cellbytelabel></td>
			<td width="7%"><cellbytelabel>Fact. Pac.</cellbytelabel></td>
			<td width="7%"><cellbytelabel>Desc. Pac.</cellbytelabel></td>
			<td width="7%"><cellbytelabel>Ajuste Pac.</cellbytelabel></td>
			<td width="6%"><cellbytelabel>Fact. Emp.</cellbytelabel></td>
			<td width="6%"><cellbytelabel>Desc. Emp.</cellbytelabel></td>
			<td width="6%"><cellbytelabel>Ajuste Emp.</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Costo Cargo</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Costo Paq.</cellbytelabel></td>			
			<td width="6%"><cellbytelabel>Gan/Perd.</cellbytelabel></td>
			<td width="3%">&nbsp;</td>
		</tr>

<%
String gCat = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
    
    if (!gCat.equals(cdo.getColValue("cat_desc"))){
	
%>
<tr class="TextHeader01">
  <td colspan="14"><%=cdo.getColValue("cat_desc")%></td>
</tr>
<%}%>
			
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("pac_id")%>-<%=cdo.getColValue("secuencia")%></td>
			<td><%=cdo.getColValue("poliza")%></td>
			<td><%=cdo.getColValue("nombre")%></td>
			<td align="center"><%=cdo.getColValue("cargos")%></td>
			<td align="right"><%if(!cdo.getColValue("monto_fact_pac").equals("0")){%><a href="javascript:viewFact('P', <%=cdo.getColValue("pac_id")%>, <%=cdo.getColValue("secuencia")%>)"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_fact_pac"))%></a><%} else {%><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_fact_pac"))%><%}%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_desc_pac"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ajustes_pac"))%></td>
			<td align="right"><%if(!cdo.getColValue("monto_fact_emp").equals("0")){%><a href="javascript:viewFact('E', <%=cdo.getColValue("pac_id")%>, <%=cdo.getColValue("secuencia")%>)"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_fact_emp"))%><%} else {%><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_fact_emp"))%><%}%></a></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_desc_emp"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ajustes_emp"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("costo"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("costo_paq"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("paquete"))%></td>
			<td align="center"><%=fb.radio("check","",false,false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%></td>
		</tr>
<%
gCat = cdo.getColValue("cat_desc");
}
%>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
		
<%=fb.formEnd()%>
		</table>
		</div>
		</div>
	</td>
</tr>
<!--
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		  <tr class="TextHeader01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextHeader02')">
			<td width="57%" align="right">T O T A L E S:</td>
			<td width="7%" align="right">&nbsp;</td>
			<td width="7%" align="right"><%//=CmnMgr.getFormattedDecimal(totalPag)%></td>
			<td width="7%" align="right"><%//=CmnMgr.getFormattedDecimal(aplicadoPag)%></td>
			<td width="6%" align="right"><%//=CmnMgr.getFormattedDecimal(ajustadoPag)%></td>
			<td width="6%" align="right"><%//=CmnMgr.getFormattedDecimal(porAplicarPag / 100)%></td>
			<td width="6%">&nbsp;</td>
			<td width="4%">&nbsp;</td>
		  </tr>
		</table>
	</td>
</tr>
-->
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
<%=fb.hidden("fHasta",fHasta)%>
<%=fb.hidden("fDesde",fDesde)%>
<%=fb.hidden("aseguradora",aseguradora)%>
<%=fb.hidden("aseguradoraDesc",aseguradoraDesc)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("beginSearch","")%>
<%=fb.hidden("noAdm",noAdm)%>
<%=fb.hidden("diferencia",diferencia)%>
<%=fb.hidden("tipoAdm",tipoAdm)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
<%=fb.hidden("fHasta",fHasta)%>
<%=fb.hidden("fDesde",fDesde)%>
<%=fb.hidden("aseguradora",aseguradora)%>
<%=fb.hidden("aseguradoraDesc",aseguradoraDesc)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("beginSearch","")%>
<%=fb.hidden("noAdm",noAdm)%>
<%=fb.hidden("diferencia",diferencia)%>
<%=fb.hidden("tipoAdm",tipoAdm)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>