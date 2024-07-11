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
String resumido = request.getParameter("resumido");
String resumido_x_aseg = request.getParameter("resumido_x_aseg");
String saldoIni = request.getParameter("saldoIni");
String aseguradora = request.getParameter("aseguradora");
	String aseguradoraDesc = request.getParameter("aseguradoraDesc");
	if (aseguradora == null) aseguradora = "";
	if (aseguradoraDesc == null) aseguradoraDesc = "";
if (resumido == null) resumido = "N";
if (resumido_x_aseg == null) resumido_x_aseg = "";
if (saldoIni == null) saldoIni = "";

String usa_fecha_apl_pago = request.getParameter("usa_fecha_apl_pago");
if (usa_fecha_apl_pago == null) usa_fecha_apl_pago = "N";
String vista = "vw_cxc_mov_adm_new";
if(usa_fecha_apl_pago.equals("S")) vista = "vw_cxc_mov_adm_fa";
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

	String codigo = request.getParameter("codigo");
	String nombre = request.getParameter("nombre");
 	String fecha_ini = request.getParameter("fecha_ini");
	String fecha_fin = request.getParameter("fecha_fin");
	if (codigo == null) codigo = "";
	if (nombre == null) nombre = ""; 
	if (fecha_ini == null) fecha_ini = CmnMgr.getCurrentDate("dd/mm/yyyy");
	if (fecha_fin == null) fecha_fin = fecha_ini; 
	if (!codigo.trim().equals("") && resumido.equals("N")) { sbFilter.append(" and upper(x.pac_id) ="); sbFilter.append(codigo.toUpperCase());}
	//if (!nombre.trim().equals("")) { sbFilter.append(" and upper(x.nombre_cliente) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
	if(!fecha_ini.trim().equals("")){sbFilter.append(" and fecha >= to_date('"); sbFilter.append(fecha_ini); sbFilter.append("','dd/mm/yyyy')"); }
	if(!fecha_fin.trim().equals("")){sbFilter.append(" and fecha <= to_date('"); sbFilter.append(fecha_fin); sbFilter.append("','dd/mm/yyyy')");}

	
	sbSql.append("select pac_id, 0 as saldo_ini, (select (select nombre_paciente from vw_adm_paciente where pac_id = x.pac_id) from dual) as nombre, (select (select nombre from tbl_adm_empresa where codigo = x.aseguradora) from dual) as aseguradora_desc, doc_type, decode(doc_type, 'PAQ', 'PAQUETE', 'FACT_A', 'FACTURA ANULADA', 'CARG/DEV', 'CARGO/DEVOLUCION', 'PAQ-A', 'PAQUETE ANULADO', 'ADJ2', 'AJUSTE RECIBO', 'FACT', 'FACTURA', 'REC', 'RECIBO', 'AJUSTE', 'AJUSTE', 'ADJ', 'AJUSTE RECIBO') doc_type_desc, (cargos + (case when ajuste_pac > 0 then ajuste_pac else 0 end) + (case when ajuste_emp > 0 then ajuste_emp else 0 end) + (case when ajuste_recibo > 0 then ajuste_recibo else 0 end) + decode (get_sec_comp_param (x.compania, 'CXC_APLICAR_PAQUETE_CS'), 'S', paquete,0)) debito, (desc_pac + desc_emp + (case when ajuste_pac < 0 then ajuste_pac else 0 end) + (case when ajuste_emp < 0 then ajuste_emp else 0 end) + pagos_aplicados + pagos_no_aplicados + (case when ajuste_recibo < 0 then ajuste_recibo else 0 end)) credito, factura_pac, factura_emp, to_char(x.fecha, 'dd/mm/yyyy') fecha, cargos, desc_pac, desc_emp, paquete, ajuste_pac, ajuste_emp, (cargos + decode(get_sec_comp_param(x.compania,'CXC_APLICAR_PAQUETE_CS'),'S', paquete,0)) - (desc_pac + desc_emp) + ajuste_pac + ajuste_emp - ");
	
	if(usa_fecha_apl_pago.equals("S")){
    sbSql.append(" (case when fecha_recibo between TO_DATE ('");
    sbSql.append(fecha_ini);
    sbSql.append("', 'dd/mm/yyyy') AND TO_DATE ('");
    sbSql.append(fecha_fin);
    sbSql.append("', 'dd/mm/yyyy') then pagos_aplicados else 0 end) - ( (pagos_no_aplicados)+ (case when fecha_recibo > TO_DATE ('");
    sbSql.append(fecha_fin);
    sbSql.append("', 'dd/mm/yyyy') then pagos_aplicados else 0 end)) ");
  } else {
    sbSql.append(" pagos_aplicados - pagos_no_aplicados ");
  }
	
	sbSql.append(" + ajuste_recibo as saldo,");
	
	
	 if(usa_fecha_apl_pago.equals("S")){
    sbSql.append(" (case when fecha_recibo between TO_DATE ('");
    sbSql.append(fecha_ini);
    sbSql.append("', 'dd/mm/yyyy') AND TO_DATE ('");
    sbSql.append(fecha_fin);
    sbSql.append("', 'dd/mm/yyyy') then pagos_aplicados else 0 end) as pagos_aplicados, ( (pagos_no_aplicados)+ (case when fecha_recibo > TO_DATE ('");
    sbSql.append(fecha_fin);
    sbSql.append("', 'dd/mm/yyyy') then pagos_aplicados else 0 end)) as pagos_no_aplicados");
  } else {
    sbSql.append(" pagos_aplicados, pagos_no_aplicados ");
  }
	
	
	sbSql.append(", ajuste_recibo, no_documento,nvl(factura_si,0) as factura_si ");
	
   sbSql.append(" from ");
   sbSql.append(vista);
   sbSql.append(" x where compania = ");
   
	sbSql.append(session.getAttribute("_companyId")); 	
	
	
	if (!aseguradora.trim().equals("")) { sbFilter.append(" and x.aseguradora = "); sbFilter.append(aseguradora);}
	if (!aseguradoraDesc.trim().equals("")) { sbFilter.append(" and exists (select null from tbl_adm_beneficios_x_admision z where nvl(z.estado,'A') = 'A' and z.prioridad = 1 and z.pac_id = x.pac_id and z.admision = x.admision and exists (select null from tbl_adm_empresa where codigo = z.empresa and upper(nombre) like '%"); sbFilter.append(aseguradoraDesc.toUpperCase()); sbFilter.append("%'))"); }
	
 	sbSql.append(sbFilter);
 	
	sbSql.append(" order by aseguradora_desc, nombre asc ");
	
	
	
         
 	if(request.getParameter("fecha_fin") != null){
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
function view(type,id){
var refType = getDBData('<%=request.getContextPath()%>','get_sec_comp_param(<%=(String) session.getAttribute("_companyId")%>,\'TP_CLIENTE_PAC\') ','dual',' ');
abrir_ventana('../cxc/movimientos.jsp?type='+refType+'&id='+id+'&fDate=<%=fecha_ini%>&tDate=<%=fecha_fin%>');}
function printList(xtraP){
var fecha_ini= document.search00.fecha_ini.value; var fecha_fin =document.search00.fecha_fin.value;  
var nombre  = document.search00.nombre.value||'ALL'; 
var codigo = document.search00.codigo.value||'ALL'; 
var resumido = document.search00.resumido.value;
var saldoIni = document.search00.saldoIni.checked ? "N":"S";
var aseguradora = document.search00.aseguradora.value||'ALL';
if(resumido=='N'){
 abrir_ventana('../cellbyteWV/report_container.jsp?reportName=cxc/rpt_mov_hospitalario.rptdesign&fDesdeParam='+fecha_ini+'&fHastaParam='+fecha_fin+'&nombreParam='+nombre+'&codigoParam='+codigo+'&aseguradoraParam='+aseguradora+'&pSaldoIni='+saldoIni+'&pCtrlHeader=false');
 } else if(resumido=='A'){
 abrir_ventana('../cellbyteWV/report_container.jsp?reportName=cxc/rpt_mov_hospitalario_res_aseg.rptdesign&fDesdeParam='+fecha_ini+'&fHastaParam='+fecha_fin+'&nombreParam='+nombre+'&codigoParam='+codigo+'&aseguradoraParam='+aseguradora+'&pSaldoIni='+saldoIni+'&pCtrlHeader=false');
 } else if(resumido=='G'){
 abrir_ventana('../cellbyteWV/report_container.jsp?reportName=cxc/rpt_mov_hospitalario_res_global.rptdesign&fDesdeParam='+fecha_ini+'&fHastaParam='+fecha_fin+'&nombreParam='+nombre+'&codigoParam='+codigo+'&aseguradoraParam='+aseguradora+'&pSaldoIni='+saldoIni+'&pCtrlHeader=false');
 }
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}
function viewDet(id,fg,saldoIni,nombre)
{
<%if(!resumido.trim().equals("S")){%>
showPopWin('../cxc/list_trx_ingresos_pac_det.jsp?codigo='+id+'&fg='+fg+'&fecha_ini=<%=fecha_ini%>&fecha_fin=<%=fecha_fin%>&saldoIni='+saldoIni+'&paciente='+nombre,winWidth*.95,winHeight*.70,null,null,''); 
<%}else{%>CBMSG.warning('SOLO  PARA  CONSULTAS DETALLADAS POR PACIENTE!');
<%}%>
}
function showEmpresaList(){abrir_ventana1('../common/search_empresa.jsp?fp=rep_aux');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SALDOS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
        <tr>
          <td align="right"><a href="javascript:printList(1)" class="Link00Bold">Imprimir (Excel)</a></td>
        </tr>
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("aseguradora",aseguradora)%>
<%=fb.hidden("codigo",codigo)%>
		<tr class="TextFilter">
			<td> 		 
				<cellbytelabel>Fecha</cellbytelabel>:
				<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="2"/>
					<jsp:param name="nameOfTBox1" value="fecha_ini"/>
					<jsp:param name="valueOfTBox1" value="<%=fecha_ini%>"/>
					<jsp:param name="nameOfTBox2" value="fecha_fin"/>
					<jsp:param name="valueOfTBox2" value="<%=fecha_fin%>"/>
				</jsp:include>
				<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
			</td>
		</tr>
         
<%=fb.formEnd()%>
		</table>
	</td>
</tr>

 <tr>
	<td class="TableLeftBorder TableRightBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
<table align="center" width="100%" cellpadding="0" cellspacing="1">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
 		<tr class="TextHeader" align="center"> 
			<td width="4%"><cellbytelabel>Tipo Doc.</cellbytelabel></td>
			<td width="7%"><cellbytelabel>No. Docto.</cellbytelabel></td>
			<td width="13%"><cellbytelabel>Nombre</cellbytelabel></td> 
			<td width="7%"><cellbytelabel>Fecha</cellbytelabel></td> 
			<td width="7%"><cellbytelabel>Cargos/Dev. </cellbytelabel></td>
			<td width="7%"><cellbytelabel>Facturas SI</cellbytelabel></td>
			<td width="7%"><cellbytelabel>Facturas Pac.</cellbytelabel></td>
			<td width="7%"><cellbytelabel>Facturas Emp.</cellbytelabel></td>
			<td width="6%"><cellbytelabel>Desc Pac.</cellbytelabel></td>
			<td width="6%"><cellbytelabel>Desc Emp.</cellbytelabel></td>
			<td width="7%"><cellbytelabel>Ajuste Pac.</cellbytelabel></td>
			<td width="7%"><cellbytelabel>Ajuste Emp.</cellbytelabel></td> 
			<td width="7%"><cellbytelabel>Pagos Apl.</cellbytelabel></td> 
			<td width="7%"><cellbytelabel>Pagos No Apl.</cellbytelabel></td> 
			<td width="7%"><cellbytelabel>Ajuste Rec.</cellbytelabel></td> 
			<td width="7%"><cellbytelabel>Saldo</cellbytelabel></td> 
			<td width="7%"><cellbytelabel>Paquete</cellbytelabel></td>
			<td width="2%">&nbsp;</td> 
		</tr>
<%
double saldoTotal =0.00,saldo=0.00,saldoAnt=0.00,facturas_pac=0.00,facturas_emp=0.00,desc_pac=0.00,desc_emp=0.00,saldoFin=0.00,ajuste_pac=0.00,ajuste_emp=0.00,cargos=0.00,paquete=0.00, pagos_aplicados = 0.00, pagos_no_aplicados = 0.00, ajuste_recibo = 0.00, tot_pagos_app = 0.00, tot_pagos_no_app = 0.00, tot_ajuste_recibo = 0.00,tot_si = 0.00;

for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	saldoAnt += Double.parseDouble(cdo.getColValue("saldo_ini"));
	cargos += Double.parseDouble(cdo.getColValue("cargos"));	
	tot_si += Double.parseDouble(cdo.getColValue("factura_si"));
	facturas_pac += Double.parseDouble(cdo.getColValue("factura_pac"));	
	facturas_emp += Double.parseDouble(cdo.getColValue("factura_emp"));
	desc_pac += Double.parseDouble(cdo.getColValue("desc_pac"));	
	desc_emp += Double.parseDouble(cdo.getColValue("desc_emp"));
	ajuste_pac += Double.parseDouble(cdo.getColValue("ajuste_pac"));
	ajuste_emp = Double.parseDouble(cdo.getColValue("ajuste_emp"));
	paquete += Double.parseDouble(cdo.getColValue("paquete"));
	saldoFin += Double.parseDouble(cdo.getColValue("saldo"));
	saldo  = Double.parseDouble(cdo.getColValue("saldo_ini"))+Double.parseDouble(cdo.getColValue("saldo"));
	pagos_aplicados  = Double.parseDouble(cdo.getColValue("pagos_aplicados"));
	pagos_no_aplicados  = Double.parseDouble(cdo.getColValue("pagos_no_aplicados"));
	ajuste_recibo  = Double.parseDouble(cdo.getColValue("ajuste_recibo"));
	saldoTotal += Double.parseDouble(cdo.getColValue("saldo_ini"))+ Double.parseDouble(cdo.getColValue("saldo"));
	tot_pagos_app += pagos_aplicados;
	tot_pagos_no_app += pagos_no_aplicados;
	tot_ajuste_recibo += ajuste_recibo;

%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
 			<td align="center"><%=cdo.getColValue("doc_type_desc")%></td>
 			<td align="center"><%=cdo.getColValue("no_documento")%></td>
			<td><%=cdo.getColValue("nombre")%></td> 
			<td><%=cdo.getColValue("fecha")%></td> 
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("cargos"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("factura_si"))%></a></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("factura_pac"))%></a></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("factura_emp"))%></a></td>			
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("desc_pac"))%></a></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("desc_emp"))%></a></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ajuste_pac"))%></a></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ajuste_emp"))%></a></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("pagos_aplicados"))%></a></td>			
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("pagos_no_aplicados"))%></a></td>			
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ajuste_recibo"))%></a></td>			
			<td align="right">
			  <%if(saldo<0){%><label  class="<%=color%>" style="cursor:pointer"><label class="RedTextBold">&nbsp;&nbsp;<%}%>
			<a href="javascript:viewDet('<%=cdo.getColValue("pac_id")%>','PAC','<%=cdo.getColValue("saldo_ini")%>','<%=cdo.getColValue("nombre")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=CmnMgr.getFormattedDecimal(saldo)%></a> 
			  <%if(saldo<0){%>&nbsp;&nbsp;</label></label><%}%>
			</td>
			<td align="right"><a href="javascript:viewDet('<%=cdo.getColValue("pac_id")%>','PAC','<%=cdo.getColValue("saldo_ini")%>','<%=cdo.getColValue("nombre")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("paquete"))%></a> </td> 
			<td align="center"><!--<a href="javascript:view('',<%=cdo.getColValue("pac_id")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">MOV</a>--></td> 
 		</tr>
<%
}
%>
	<tr class="TextHeader02" align="center">
			<td colspan="4" align="right">TOTALES PAGINA</td>
			<!--<td align="right"><%=CmnMgr.getFormattedDecimal(saldoAnt)%></td>-->
			<td align="right"><%=CmnMgr.getFormattedDecimal(cargos)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(tot_si)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(facturas_pac)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(facturas_emp)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(desc_pac)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(desc_emp)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(ajuste_pac)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(ajuste_emp)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(tot_pagos_app)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(tot_pagos_no_app)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(tot_ajuste_recibo)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(saldoFin)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(paquete)%></td>
			<td>&nbsp;</td> 
		</tr>
		<%if(resumido.trim().equals("S")){%>
		<tr class="TextHeader01" align="center">
			<td colspan="3" align="right"> </td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="center" colspan="2"><%=CmnMgr.getFormattedDecimal(facturas_pac+facturas_emp)%></td> 
			<td align="center" colspan="2"><%=CmnMgr.getFormattedDecimal(desc_pac+desc_emp)%></td> 
			<td align="center" colspan="2"><%=CmnMgr.getFormattedDecimal(ajuste_pac+ajuste_emp)%></td> 
			<td align="center" colspan="1"><%=CmnMgr.getFormattedDecimal(tot_pagos_app)%></td> 
			<td align="center" colspan="1"><%=CmnMgr.getFormattedDecimal(tot_pagos_no_app)%></td> 
			<td align="center" colspan="1"><%=CmnMgr.getFormattedDecimal(tot_ajuste_recibo)%></td> 
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td>&nbsp;</td> 
		</tr>
		<%}%>

		 <%=fb.formEnd(true)%>
   </table>
 </div>
</div>

		
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	</td>
</tr>
</table>
</body>
</html>
<%
}
%>