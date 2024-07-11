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
/*
=========================================================================
=========================================================================
*/
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
StringBuffer sbFilterFF = new StringBuffer();

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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

	String tipo = request.getParameter("tipo");
	String codigo = request.getParameter("codigo");
	String nombre = request.getParameter("nombre");
	String estado = request.getParameter("estado");
	String fecha_ini = request.getParameter("fecha_ini");
	String fecha_fin = request.getParameter("fecha_fin");
	String filtro_fecha_fact = request.getParameter("filtro_fecha_fact");
	String refer_to = request.getParameter("refer_to");
	String tipoOtro = request.getParameter("tipoOtro");
	String usarNombre = request.getParameter("usarNombre");
	String filterZeros = request.getParameter("filterZeros") == null ? "" : request.getParameter("filterZeros");
	if (tipo == null) tipo = "";
	if (codigo == null) codigo = "";
	if (nombre == null) nombre = "";
	if (estado == null) estado = "";
	if (refer_to == null) refer_to = "";
	if (tipoOtro == null) tipoOtro = "";
	if (fecha_ini == null) fecha_ini = CmnMgr.getCurrentDate("dd/mm/yyyy");
	if (fecha_fin == null) fecha_fin = fecha_ini;
	if (filtro_fecha_fact == null) filtro_fecha_fact = "";
	if (usarNombre == null) usarNombre = "";
	if (!tipo.trim().equals("")) { sbFilter.append(" and refer_type = "); sbFilter.append(tipo);}
	if (!codigo.trim().equals("")) { sbFilter.append(" and upper(x.refer_id) like '%"); sbFilter.append(codigo.toUpperCase()); sbFilter.append("%'"); }
	//if (!nombre.trim().equals("")) { sbFilter.append(" and upper(x.nombre_cliente) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
	if (!estado.trim().equals("")) { sbFilter.append(" and x.estatus = '"); sbFilter.append(estado); sbFilter.append("'"); }
	if (filtro_fecha_fact.trim().equals("Y")) {
		sbFilterFF.append(" and trunc(x.fecha_factura) <= to_date('");
		sbFilterFF.append(fecha_fin);
		sbFilterFF.append("', 'dd/mm/yyyy')");
	}
	if (refer_to.equalsIgnoreCase("CXCO")) {
			if (!tipoOtro.trim().equals("")) {
				sbFilter.append(" and exists (select null from tbl_cxc_cliente_particular where compania = x.compania and codigo = x.refer_id and tipo_cliente = ");
				sbFilter.append(tipoOtro);
				sbFilter.append(")");
			}
		}
	
	

	if (!nombre.trim().equals("")) sbSql.append("select * from (");

	sbSql.append("select refer_type as tipo,(select refer_to from tbl_fac_tipo_cliente tc where tc.compania = x.compania and tc.codigo = x.refer_type)refer_to, (select descripcion from tbl_fac_tipo_cliente tc where tc.compania = x.compania and tc.codigo = x.refer_type) refer_desc, x.refer_id as codigo");
	if (usarNombre.equalsIgnoreCase("S") || !nombre.trim().equals("")) sbSql.append(", decode(x.refer_type,(select get_sec_comp_param(x.compania,'TP_CLIENTE_PAC') from dual),(select nombre_paciente from vw_adm_paciente where pac_id = x.refer_id),(select getNombreCliente(x.compania,x.refer_type,x.refer_id) from dual)) as nombre");
	else sbSql.append(", ' ' as nombre");
	sbSql.append(", sum((case when trunc(x.doc_date) < to_date('");
	sbSql.append(fecha_ini);
	sbSql.append("', 'dd/mm/yyyy')");
	if (filtro_fecha_fact.trim().equals("Y")) {
		sbSql.append(" and trunc(x.fecha_factura) < to_date('");
		sbSql.append(fecha_ini);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	sbSql.append(" then nvl(x.debito,0)- (nvl(x.credito,0)/*+nvl(x.aj_rec,0)*/) /*- nvl(x.pago_no_aplicado, 0)*/ else 0 end)) saldo_anterior, sum((case when trunc(x.doc_date) between to_date('");
	sbSql.append(fecha_ini);
	sbSql.append("', 'dd/mm/yyyy') and to_date('");
	sbSql.append(fecha_fin);
	sbSql.append("', 'dd/mm/yyyy')");
	sbSql.append(sbFilterFF.toString());
	sbSql.append(" then nvl(x.debito,0)- nvl(x.credito,0) else 0 end)) movimiento, sum(case when trunc(x.doc_date) <= to_date('");
	sbSql.append(fecha_fin);
	sbSql.append("', 'dd/mm/yyyy')");
	sbSql.append(sbFilterFF.toString());
	sbSql.append(" then nvl(x.debito,0)-(nvl(x.credito,0)/*+nvl(x.aj_rec,0)*/)/* - nvl(x.pago_no_aplicado,0)*/ else 0 end) saldo, sum((case when trunc(x.doc_date) between to_date('");
	sbSql.append(fecha_ini);
	sbSql.append("', 'dd/mm/yyyy') and to_date('");
	sbSql.append(fecha_fin);
	sbSql.append("', 'dd/mm/yyyy')");
	sbSql.append(sbFilterFF.toString());
	sbSql.append(" then facturas else 0 end)) facturas, sum((case when trunc(x.doc_date) between to_date('");
	sbSql.append(fecha_ini);
	sbSql.append("', 'dd/mm/yyyy') and to_date('");
	sbSql.append(fecha_fin);
	sbSql.append("', 'dd/mm/yyyy')");
	sbSql.append(sbFilterFF.toString());
	sbSql.append(" then nvl(pagos,0) else 0 end)) pagos, sum((case when trunc(x.doc_date) between to_date('");
	sbSql.append(fecha_ini);
	sbSql.append("', 'dd/mm/yyyy') and to_date('");
	sbSql.append(fecha_fin);
	sbSql.append("', 'dd/mm/yyyy')");
	sbSql.append(sbFilterFF.toString());
	sbSql.append(" then ajustes else 0 end)) ajustes,sum((case when trunc(x.doc_date) between to_date('");
	sbSql.append(fecha_ini);
	sbSql.append("', 'dd/mm/yyyy') and to_date('");
	sbSql.append(fecha_fin);
	sbSql.append("', 'dd/mm/yyyy')");
	sbSql.append(sbFilterFF.toString());
	sbSql.append(" then nvl(aj_rec,0) else 0 end)) as aj_rec,sum((case when trunc(x.doc_date) between to_date('");
	sbSql.append(fecha_ini);
	sbSql.append("', 'dd/mm/yyyy') and to_date('");
	sbSql.append(fecha_fin);
	sbSql.append("', 'dd/mm/yyyy')");
	sbSql.append(sbFilterFF.toString());
	sbSql.append(" then nvl(pago_no_aplicado,0) else 0 end)) as por_aplicar ,(select oc.descripcion from tbl_cxc_cliente_particular p,tbl_cxc_tipo_otro_cliente oc where p.compania = x.compania and to_char(p.codigo) = x.refer_id and oc.id= p.tipo_cliente and p.compania=oc.compania) as tipo_cliente_o, sum((case when trunc (x.doc_date) between to_date('");
	sbSql.append(fecha_ini);
	sbSql.append("', 'dd/mm/yyyy') and to_date('");
	sbSql.append(fecha_fin);
	sbSql.append("', 'dd/mm/yyyy') then nvl (descuento, 0) else 0 end)) descuento from vw_cxc_mov_new x where x.compania = ");

	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and trunc (x.doc_date) <= to_date('");
	sbSql.append(fecha_fin);
	sbSql.append("', 'dd/mm/yyyy')");
 	sbSql.append(sbFilter);
 	sbSql.append(" group by x.refer_type, x.compania, x.refer_id");

	if (!nombre.trim().equals("")) { sbSql.append(") where upper(nombre) like '%"); sbSql.append(nombre.toUpperCase()); sbSql.append("%'"); }

	/*sbSql.append("select * from (");
	sbSql.append("select 'P' as tipo, a.pac_id as codigo, a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre)||decode(a.primer_apellido,null,'',' '||a.primer_apellido)||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_de_casada,null,'',' '||a.apellido_de_casada)) as nombre, a.estatus as estado, decode(estatus,'A','ACTIVO','I','INACTIVO',estatus) as status, nvl((select  sum(nvl(x.debito,0) - nvl(x.credito,0) - nvl(x.pago_no_aplicado, 0))saldo  from vw_cxc_movimiento x where x.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
    sbSql.append(" and x.ref_type = 'P' and x.pac_id = a.pac_id ),0)as saldo from tbl_adm_paciente a");
	sbSql.append(" union all ");
	sbSql.append("select 'E', a.codigo, a.nombre, a.estado, decode(a.estado,'A','ACTIVO','I','INACTIVO',a.estado) as status, nvl((select  sum(nvl(b.debito,0)- nvl(b.credito,0))saldo  from vw_cxc_movimiento b where b.compania =");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and b.ref_type = 'E' and b.empresa = a.codigo ),0)as  saldo from tbl_adm_empresa a");
	sbSql.append(") where tipo is not null");
	sbSql.append(sbFilter);
	*/
        
    if (!filterZeros.equals("")){
      StringBuffer sbFZeros = new StringBuffer();
      sbFZeros.append(" select fz.* from(");
      sbFZeros.append(sbSql.toString());
      sbFZeros.append(") fz where fz.saldo != 0 ");
      sbSql = sbFZeros;
    }

	if(request.getParameter("tipo") != null){
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");
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
	if (rowCount==0) pVal=0;
	else pVal=preVal;
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Saldos - '+document.title;
var forceList = true;
function view(type,id){abrir_ventana('../cxc/movimientos.jsp?type='+type+'&id='+id+'&fDate=<%=fecha_ini%>&tDate=<%=fecha_fin%>&filtro_fecha_fact=<%=filtro_fecha_fact%>');}
function printRFP(ref_type,ref_id,referTo){var fecha_ini= document.search00.fecha_ini.value; var fecha_fin =document.search00.fecha_fin.value;  if(ref_id!='')abrir_ventana('../facturacion/print_estado_cuenta.jsp?referTo='+referTo+'&refId='+ref_id+'&refType='+ref_type+'&fDate='+fecha_ini+'&tDate='+fecha_fin);else CBMSG.warning('El cliente no tiene referencia en el sistema.');
}
function setCliente(ref_type,ref_id,referTo){if(ref_id!='')abrir_ventana('../cxc/reg_cliente_unificado.jsp?referTo='+referTo+'&refId='+ref_id+'&refType='+ref_type);else CBMSG.warning('El cliente no tiene referencia en el sistema.');
}
function printList(xtraP){
var fecha_ini= document.search00.fecha_ini.value; var fecha_fin =document.search00.fecha_fin.value;
var filtro_fecha_fact = document.search00.filtro_fecha_fact.value;
var tipo = document.search00.tipo.value;
var tipoOtro = document.search00.tipoOtro.value;
var nombre  = document.search00.nombre.value;
var usarNombre = document.search00.usarNombre.value;
var codigo = document.search00.codigo.value;
var refer_to = document.search00.refer_to.value;
var filterZeros = document.search00.filterZeros.checked ? "Y": "";
if(!xtraP)abrir_ventana('../cxc/print_list_saldos.jsp?fecha_ini='+fecha_ini+'&fecha_fin='+fecha_fin+'&filtro_fecha_fact='+filtro_fecha_fact+'&nombre='+nombre+'&tipo='+tipo+'&tipoOtro='+tipoOtro+'&usarNombre='+usarNombre+'&codigo='+codigo+'&refer_to='+refer_to+'&filterZeros='+filterZeros);
else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=cxc/rpt_list_saldos.rptdesign&fecha_ini='+fecha_ini+'&fecha_fin='+fecha_fin+'&filtro_fecha_fact='+filtro_fecha_fact+'&nombre='+nombre+'&tipo='+tipo+'&tipoOtro='+tipoOtro+'&usarNombre='+usarNombre+'&codigo='+codigo+'&refer_to='+refer_to+'&filterZeros='+filterZeros+'&pCtrlHeader=false');
}
function setReferTo(obj){var referTo=getSelectedOptionTitle(obj,'');document.search00.refer_to.value=referTo;chkOther(referTo);}
function doAction(){chkOther('<%=refer_to%>');}
function chkOther(referTo){if(referTo!='CXCO')document.search00.tipoOtro.value=''; document.search00.tipoOtro.disabled=(referTo!='CXCO');}
function gestion(type,id,referTo){abrir_ventana('../cxc/seguimiento.jsp?mode=edit&tipo='+type+'&clientId='+id+'&referTo='+referTo+'&fechaIni=<%=fecha_ini%>&fechaFin=<%=fecha_fin%>&filtro_fecha_fact=<%=filtro_fecha_fact%>');}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SALDOS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
        <tr>
          <td align="right"><a href="javascript:printList()" class="Link00Bold">Imprimir</a>
          &nbsp;&nbsp;&nbsp;<a href="javascript:printList(1)" class="Link00Bold">Imprimir (Excel)</a></td>
        </tr>
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("refer_to", refer_to)%>
		<tr class="TextFilter">
			<td>Tipo
				<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion,refer_to from tbl_fac_tipo_cliente where compania = "+(String) session.getAttribute("_companyId")+" and (activo_inactivo = 'A' or to_char(codigo) = get_sec_comp_param(compania, 'TP_CLIENTE_PAC')) order by descripcion","tipo",tipo,false,false,0,"Text10","width:150px","onChange=\"javascript:setReferTo(this);\"","","T")%>		
				<%=fb.select(ConMgr.getConnection(),"select id, descripcion, id from tbl_cxc_tipo_otro_cliente where estado = 'A' and compania = "+(String) session.getAttribute("_companyId")+" order by descripcion","tipoOtro",tipoOtro,false,false,0,"Text10","","","","T")%>		
				<%//=fb.select("tipo","P=PACIENTE,E=EMPRESA",tipo,false,false,0,"Text10",null,null,null,"T")%>
				<cellbytelabel>C&oacute;digo</cellbytelabel>
				<%=fb.textBox("codigo",codigo,false,false,false,10,"Text10",null,null)%>
				<cellbytelabel>Nombre</cellbytelabel>
				<%=fb.textBox("nombre",nombre, false,false,false,30,"Text10",null,null)%>
				<cellbytelabel>Fecha</cellbytelabel>:
				<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="2"/>
					<jsp:param name="nameOfTBox1" value="fecha_ini"/>
					<jsp:param name="valueOfTBox1" value="<%=fecha_ini%>"/>
					<jsp:param name="nameOfTBox2" value="fecha_fin"/>
					<jsp:param name="valueOfTBox2" value="<%=fecha_fin%>"/>
				</jsp:include>
				
			</td>
		</tr>
        <tr class="TextFilter">
			<td>
            Usa Fecha Factura?<%=fb.select("filtro_fecha_fact","N=No,Y=Si",filtro_fecha_fact,false,false,0,"Text10",null,null,null,"")%>
				&nbsp;Usar Nombre?<%=fb.select("usarNombre","S=Si,N=No",usarNombre,false,false,0,"Text10",null,null,null,"")%>
                <label class="pointer"><%=fb.checkbox("filterZeros","Y",filterZeros.equals("Y"),false)%>No saldo 0</label>
                
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
			</td>
		</tr>
<%=fb.formEnd()%>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("fecha_ini",fecha_ini)%>
<%=fb.hidden("fecha_fin",fecha_fin)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("filtro_fecha_fact",filtro_fecha_fact)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("tipoOtro",tipoOtro)%>
<%=fb.hidden("refer_to", refer_to)%>
<%=fb.hidden("usarNombre", usarNombre)%>
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
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("fecha_ini",fecha_ini)%>
<%=fb.hidden("fecha_fin",fecha_fin)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("filtro_fecha_fact",filtro_fecha_fact)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("tipoOtro",tipoOtro)%>
<%=fb.hidden("refer_to", refer_to)%>
<%=fb.hidden("usarNombre", usarNombre)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
		<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="list" exclude="0,5">
		<tr class="TextHeader" align="center">
			<td width="16%">&nbsp;</td>
			<td width="5%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="16%"><cellbytelabel>Nombre</cellbytelabel></td> 
			<td width="7%"><cellbytelabel>S. Anterior</cellbytelabel></td>
			<td width="7%"><cellbytelabel>Facturas</cellbytelabel></td>
			<td width="7%"><cellbytelabel>AJ. FACT</cellbytelabel></td>
			<td width="7%"><cellbytelabel>P. Aplic. Fact.</cellbytelabel></td>			
			<td width="7%"><cellbytelabel>Por Aplicar</cellbytelabel></td>
			<td width="6%"><cellbytelabel>AJ. REC</cellbytelabel></td>		
			<td width="6%"><cellbytelabel>Saldo Final</cellbytelabel></td>
			<td width="6%"><cellbytelabel>Desc.</cellbytelabel></td>
			<td width="3%">&nbsp;</td>
			<td width="3%">&nbsp;</td>
			<td width="3%">&nbsp;</td>
		</tr>
<%
double saldo = 0.00,saldoAnt= 0.00,facturas= 0.00,pagos= 0.00,ajustes= 0.00,saldoFin= 0.00,porAplicar=0.00,aj_rec=0.00,descuento=0.00;
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	saldoAnt += Double.parseDouble(cdo.getColValue("saldo_anterior"));
	facturas += Double.parseDouble(cdo.getColValue("facturas"));	
	ajustes += Double.parseDouble(cdo.getColValue("ajustes"));
	pagos += Double.parseDouble(cdo.getColValue("pagos"));	
	porAplicar += Double.parseDouble(cdo.getColValue("por_aplicar"));
	aj_rec += Double.parseDouble(cdo.getColValue("aj_rec"));
	saldoFin += Double.parseDouble(cdo.getColValue("saldo"));
	saldo = Double.parseDouble(cdo.getColValue("saldo"));
	descuento += Double.parseDouble(cdo.getColValue("descuento"));

%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="left"><%=cdo.getColValue("refer_desc")%> &nbsp;-&nbsp; <%=cdo.getColValue("tipo_cliente_o")%> </td>
			<td align="center"><%=cdo.getColValue("codigo")%></td>
			<td align="right"><a href="javascript:gestion('<%=cdo.getColValue("tipo")%>','<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("refer_to")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=cdo.getColValue("nombre")%></a></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("saldo_anterior"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("facturas"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ajustes"))%></td>			
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("pagos"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("por_aplicar"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("aj_rec"))%></td>
			<td align="right">
			  <%if(saldo<0){%><label  class="<%=color%>" style="cursor:pointer"><label class="RedTextBold">&nbsp;&nbsp;<%}%>
				<%=CmnMgr.getFormattedDecimal(saldo)%>
			  <%if(saldo<0){%>&nbsp;&nbsp;</label></label><%}%>
			</td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("descuento"))%></td>
			<td align="center"><a href="javascript:view('<%=cdo.getColValue("tipo")%>',<%=cdo.getColValue("codigo")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Ver</a></td>
			<td align="center"><a href="javascript:printRFP('<%=cdo.getColValue("tipo")%>','<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("refer_to")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">EC</a></td>
			<td align="center"><!--<a href="javascript:setCliente('<%=cdo.getColValue("tipo")%>','<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("refer_to")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">UNIF.</a>--></td>


		</tr>
<%
}
%>
<tr class="TextHeader02" align="center">
			<td colspan="3" align="right">TOTALES</td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(saldoAnt)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(facturas)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(ajustes)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(pagos)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(porAplicar)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(aj_rec)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(saldoFin)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(descuento)%></td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>

		</table>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("fecha_ini",fecha_ini)%>
<%=fb.hidden("fecha_fin",fecha_fin)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("filtro_fecha_fact",filtro_fecha_fact)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("tipoOtro",tipoOtro)%>
<%=fb.hidden("refer_to", refer_to)%>
<%=fb.hidden("usarNombre", usarNombre)%>
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
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("fecha_ini",fecha_ini)%>
<%=fb.hidden("fecha_fin",fecha_fin)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("filtro_fecha_fact",filtro_fecha_fact)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("tipoOtro",tipoOtro)%>
<%=fb.hidden("refer_to", refer_to)%>
<%=fb.hidden("usarNombre", usarNombre)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}
%>