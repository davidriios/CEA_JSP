<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/*------------------------------------------------------------------------------------------------*/
/** Check whether the user is logged in or not what access rights he has----------------------------
0	SISTEMA         TODO        ACCESO TODO SISTEMA             A
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
	if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String id = request.getParameter("id");
String fp= request.getParameter("fp");
String fg= request.getParameter("fg");
String index = request.getParameter("index");
String nt = request.getParameter("nt");
String fecha_ini = request.getParameter("fecha_ini");
String fecha_fin = request.getParameter("fecha_fin");
String factura_dgi = request.getParameter("factura_dgi");
String tipo_doc = request.getParameter("tipo_doc");
String tipo_emision = request.getParameter("tipo_emision");
String cod_sucursal = request.getParameter("cod_sucursal");
String punto_de_fact = request.getParameter("punto_de_fact");
String tipo_de_contr = request.getParameter("tipo_de_contr");
String ruc_emisor = request.getParameter("ruc_emisor");
String dv_emisor = request.getParameter("dv_emisor");
String razon_social_emi = request.getParameter("razon_social_emi");
String codigo = request.getParameter("codigo");
String razon_social_rec = request.getParameter("razon_social_rec");
String tipo_receptor = request.getParameter("tipo_receptor");
String id_pasaporte = request.getParameter("id_pasaporte");
String pais_recep = request.getParameter("pais_recep");
String sum_items = request.getParameter("sum_items");
String itbms = request.getParameter("itbms");
String valor_isc = request.getParameter("valor_isc");
String t_impuestos = request.getParameter("t_impuestos");
String impreso = request.getParameter("impreso");
String ruc_receptor =request.getParameter("ruc_receptor");
String touch = request.getParameter("touch") == null ? "" : request.getParameter("touch");

StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
StringBuffer sbPrintListFilter = new StringBuffer();

int iconHeight = touch.equalsIgnoreCase("y")?36:20;
int iconWidth = touch.equalsIgnoreCase("y")?36:20;
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
if(fecha_ini==null) fecha_ini = fecha;
if(fecha_fin==null) fecha_fin = fecha;
if(factura_dgi==null) factura_dgi = "";
if(tipo_doc==null) tipo_doc = "";
if(tipo_emision==null) tipo_emision = "";
if(cod_sucursal==null) cod_sucursal = "";
if(punto_de_fact==null) punto_de_fact = "";
if(tipo_de_contr==null) tipo_de_contr = "";
if(dv_emisor==null) dv_emisor = "";
if(razon_social_emi==null) razon_social_emi = "";
if(codigo==null) codigo = "";
if(razon_social_rec==null) razon_social_rec = "";
if(tipo_receptor==null) tipo_receptor = "";
if(id_pasaporte==null) id_pasaporte = "";
if(pais_recep==null) pais_recep = "";
if(sum_items==null) sum_items = "";
if(itbms==null) itbms = "";
if(valor_isc==null) valor_isc = "";
if(t_impuestos==null) t_impuestos = "";
if(impreso==null) impreso = "";
if(ruc_receptor==null) ruc_receptor = "";
if(fp==null) fp = "";
if(fg==null) fg = "";

StringBuffer sbCaja = new StringBuffer();
StringBuffer sbUsuario = new StringBuffer();
if (UserDet.getUserProfile().contains("0")) {
	sbCaja.append("select codigo id, trim(to_char(codigo,'009')) ||' - '||descripcion as descripcion from tbl_cja_cajas where compania = ");
	sbCaja.append((String) session.getAttribute("_companyId"));
	sbCaja.append(" and estado = 'A' order by descripcion");
} else {
	sbCaja.append("select codigo id, trim(to_char(codigo,'009')) ||' - '||descripcion as descripcion from tbl_cja_cajas where compania = ");
	sbCaja.append((String) session.getAttribute("_companyId"));
	sbCaja.append(" and codigo in (");
	sbCaja.append((String) session.getAttribute("_codCaja"));
	sbCaja.append(") and ip = '");
	sbCaja.append(request.getRemoteAddr());
	sbCaja.append("' and estado = 'A' order by descripcion");
}
sbUsuario.append("select user_name, name from tbl_sec_users u where user_status = 'A' and exists (select null from tbl_cja_cajera c where compania = ");
sbUsuario.append((String) session.getAttribute("_companyId"));
sbUsuario.append(" and c.usuario = u.user_name) order by name");
if(request.getMethod().equalsIgnoreCase("GET"))
{
	CommonDataObject p = SQLMgr.getData("select nvl(get_sec_comp_param("+session.getAttribute("_companyId")+",'FAC_IMPRESO_SI_DGI'),'N') as impresoSi from dual");
	if (p == null) {

		p = new CommonDataObject();
		p.addColValue("impresoSi","N");

	}
	int recsPerPage=100;
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

	if (!codigo.trim().equals("")){
		sbFilter.append(" and a.codigo like'");
		sbFilter.append(codigo);
		sbFilter.append("'");
	}
	if (!razon_social_rec.trim().equals("")){
		sbFilter.append(" and a.cliente like '%");
		sbFilter.append(razon_social_rec);
		sbFilter.append("%'");
	}
	if (!fecha_ini.trim().equals("")){
		sbFilter.append(" and trunc(a.fecha) >= to_date('");
		sbFilter.append(fecha_ini);
		sbFilter.append("', 'dd/mm/yyyy')");
	}
	if (!fecha_fin.trim().equals("")){
		sbFilter.append(" and trunc(a.fecha) <= to_date('");
		sbFilter.append(fecha_fin);
		sbFilter.append("', 'dd/mm/yyyy')");
	}

	sbPrintListFilter.append(sbFilter.toString());
		sbSql.append("SELECT a.id, decode(a.codigo_dgi, '', a.codigo, a.codigo_dgi, a.codigo_dgi) factura_dgi, decode(a.tipo_docto, 'FACP', '01', 'FACT', '01', 'ND', '07', 'NDP', '07', 'NC', '04', 'NCP', '04') tipo_doc, to_char(a.fecha, 'YYYYMMDD') fecha, ( SELECT param_value FROM tbl_sec_comp_param WHERE param_name = 'TIPO_DE_EMISION' ) tipo_emision, ( SELECT param_value FROM tbl_sec_comp_param WHERE param_name = 'COD_SUCURSAL' ) cod_sucursal, ( SELECT param_value FROM tbl_sec_comp_param WHERE param_name = 'PUNTO_DE_FACT' ) punto_de_fact, ( SELECT param_value FROM tbl_sec_comp_param WHERE param_name = 'TIPO_DE_CONTRIBUYENTE' ) tipo_de_contr, c.ruc ruc_emisor, c.digito_verificador dv_emisor, c.nombre razon_social_emi, a.codigo, ( CASE WHEN a.tipo_docto = 'FACT' THEN a.monto - nvl(( SELECT SUM(monto) FROM tbl_fac_detalle_factura f WHERE f.compania = a.compania AND f.fac_codigo = a.codigo AND EXISTS( SELECT NULL FROM tbl_cds_centro_servicio cds WHERE cds.codigo = f.centro_servicio AND cds.tipo_cds = 'T' AND cds.codigo != 0 ) ), 0) ELSE a.monto END ) monto, nvl(a.impuesto, 0) itbms, a.cod_ref, nvl(( SELECT decode(ap.tipo_id_paciente, 'C', '02', 'P', '04') FROM tbl_adm_paciente ap WHERE ap.pac_id = a.pac_id ), '02') tipo_receptor, nvl(a.impreso, 'N') impreso, replace(decode(a.ruc_cedula, 'RUC', '', a.ruc_cedula, a.ruc_cedula), '-D') ruc_receptor, ( CASE WHEN a.facturar_a = 'E' THEN decode(a.cliente, a.cliente, a.campo4) ELSE a.cliente END ) razon_social_rec, ( SELECT ( CASE WHEN ap.tipo_id_paciente = 'C' THEN decode(ap.pasaporte, ap.pasaporte, '') ELSE ap.pasaporte END ) FROM tbl_adm_paciente ap WHERE ap.pac_id = a.pac_id ) id_pasaporte, ( SELECT ( CASE WHEN ap.tipo_id_paciente = 'C' THEN decode(b.nombre, b.nombre, '') ELSE b.nombre END ) FROM tbl_adm_paciente ap, tbl_sec_pais b WHERE ap.nacionalidad = b.codigo AND ap.pac_id = a.pac_id ) pais_recep, nvl(( SELECT SUM(nvl(precio, 0) * nvl(cantidad, 1)) itemtotalprice FROM tbl_fac_dgi_docto_det dd WHERE dd.id = a.id AND dd.compania = a.compania ), a.monto) sum_items, 0 valor_isc, nvl((a.impuesto + 0), 0) t_impuestos, to_char(nvl(a.fecha_impresion, impresion_timestamp), 'dd/mm/yyyy hh12:mi:ss am') fecha_impresion, ( SELECT estatus FROM tbl_fac_factura f WHERE f.codigo = a.codigo AND f.compania = a.compania AND f.estatus <> 'A' ) estado_de_factura, a.facturar_a, a.pac_id FROM tbl_fac_dgi_documents a, tbl_sec_compania c WHERE a.compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(" and a.compania = c.codigo");
	if (!impreso.trim().equals("")){
		sbSql.append(" and nvl(a.impreso, 'N') = '");
		sbSql.append(impreso);
		sbSql.append("'");
	}
		sbSql.append(sbFilter.toString());

		sbSql.append(" order by a.fecha desc, nvl(a.fecha_impresion,impresion_timestamp) desc");
		
		if(request.getParameter("impreso") != null){
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");
		System.out.println("sbFilter.toString()="+sbFilter.toString());
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
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Facturas - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}

function printExcel(){
	var codigo = document.search01.codigo.value;
	var razon_social_rec = document.search01.razon_social_rec.value;
	var impreso   = document.search01.impreso.value;
	var fecha_ini = document.search01.fecha_ini.value;
	var fecha_fin = document.search01.fecha_fin.value;

	abrir_ventana("../facturacion/informe_ventas1027_excel.jsp?codigo="+codigo+"&razon_social_rec="+razon_social_rec+"&impreso="+impreso+"&fecha_ini="+fecha_ini+"&fecha_fin="+fecha_fin+"");
	
}
function printFact(i, flag)
{
	var id = eval('document.form0.id'+i).value;
	var codigo = eval('document.form0.codigo'+i).value;
	var tipo_docto = eval('document.form0.tipo_docto'+i).value;
	var ruc = eval('document.form0.ruc_receptor'+i).value;
	var _height = 0.75;
	var _width = 0.80;
	<%if(fg.equals("documentos_pendientes")){%>
	_height = 0.45;
	_width = 0.80;
	<%}%>
if(flag=='2') showPopWin('../facturacion/ver_impresion_dgi.jsp?fp=docto_dgi_list&actType=2&docType=DGI&docId='+id+'&docNo='+codigo+'&tipoDocto='+tipo_docto+'&ruc='+ruc,winWidth*.75,350,null,null,'');
else if(flag=='1') showPopWin('../common/run_process.jsp?fp=docto_dgi_list&actType=2&docType=DGI&docId='+id+'&docNo='+codigo+'&tipo='+tipo_docto+'&ruc='+ruc,winWidth*_width,winHeight*_height,null,null,'');
else if(flag=='5') showPopWin('../common/run_process.jsp?fp=docto_dgi_list&actType=5&docType=DGI&docId='+id+'&docNo='+codigo+'&tipo='+tipo_docto+'&ruc='+ruc,winWidth*_width,winHeight*_height,null,null,'');
}
function goOption(x)
{   var tipo_docto = document.search01.tipo_docto.value;
	var codigoDesde = document.search01.codigoDesde.value;
	var codigoHasta = document.search01.codigoHasta.value;
	var fechaDesde = document.search01.fechaDesde.value;
	var fechaHasta = document.search01.fechaHasta.value;
	var rucCed = document.search01.ruc_receptor.value;
	if(x>=3 && x<=6){
	if(tipo_docto=='FACP') tipo_docto = 'FACT';
	else if(tipo_docto=='NCP') tipo_docto = 'NC';
	else if(tipo_docto=='NDP') tipo_docto = 'ND';
	}

	if(x==1) showPopWin('../common/run_process.jsp?fp=docto_dgi_list&actType=3&docType=DGI'+'&docNo=X',winWidth*.75,winHeight*.65,null,null,'');
	else if(x==2) showPopWin('../common/run_process.jsp?fp=docto_dgi_list&actType=4&docType=DGI'+'&docNo=X',winWidth*.75,winHeight*.65,null,null,'');
	else if(x==3){if(tipo_docto!='' && codigoDesde !=''&& codigoHasta !='' )showPopWin('../common/run_process.jsp?fp=docto_dgi_list&actType=55&docType=DGI&docId=0&transHasta='+codigoHasta+'&transDesde='+codigoDesde+'&tipo='+tipo_docto+'&fg=RN',winWidth*.75,winHeight*.70,null,null,'');else CBMSG.warning('Seleccione tipo de Documento y Rango de Facturas');}
	else if(x==4){if(tipo_docto!='' && fechaDesde !='' && fechaHasta !='')showPopWin('../common/run_process.jsp?fp=docto_dgi_list&actType=55&docType=DGI&docId=0&transHasta='+fechaDesde+'&transDesde='+fechaHasta+'&tipo='+tipo_docto+'&fg=RF',winWidth*.75,winHeight*.70,null,null,'');else{ if(fechaDesde =='' || fechaHasta ==''){CBMSG.warning('Seleccione tipo de Documento y rango de Fecha');}else{ CBMSG.warning('Seleccione tipo de Documento');}}}
	else if(x==5){
		if(tipo_docto!='' && rucCed!='')showPopWin('../common/run_process.jsp?fp=docto_dgi_list&actType=55&docType=DGI&docId=0&ruc='+rucCed+'&tipo='+tipo_docto+'&fg=RK',winWidth*.75,winHeight*.70,null,null,'');
		else{
				if(rucCed==''){CBMSG.warning('Seleccione tipo de Documento y Ruc/ Cedula de Cliente')}
			else{ CBMSG.warning('Seleccione tipo de Documento') ;}
	}}
	else if(x==6){if(tipo_docto!='' && codigoDesde !=''&& codigoHasta !='' )showPopWin('../common/run_process.jsp?fp=docto_dgi_list&actType=55&docType=DGI&docId=0&transHasta='+codigoHasta+'&transDesde='+codigoDesde+'&tipo='+tipo_docto+'&fg=LIST',winWidth*.75,winHeight*.70,null,null,'');else CBMSG.warning('Seleccione tipo de Documento y Rango de Facturas');}
	else if(x==7){showPopWin('../common/execute_fiscal_cmds.jsp?f_command=0',winWidth*.55,winHeight*.30,null,null,'');}
	else if(x==8){showPopWin('../common/general_process.jsp?fp='+document.search01.fp.value+'&fecha_ini='+document.search01.fecha_ini.value+'&fecha_fin='+document.search01.fecha_fin.value+'&us_fac='+document.search01.usuario_factura.value+'&cia='+<%=((String) session.getAttribute("_companyId"))%>,winWidth*.55,winHeight*.30,null,null,'');}

}

function printDoct(i)
{
	var id = eval('document.form0.id'+i).value;
	var codigo = eval('document.form0.codigo'+i).value;
	var tipo_docto = eval('document.form0.tipo_docto'+i).value;
	var ruc = eval('document.form0.ruc_receptor'+i).value;
	abrir_ventana('../facturacion/print_fact.jsp?fp=docto_dgi_list&actType=2&docType=DGI&docId='+id+'&docNo='+codigo+'&tipo='+tipo_docto+'&ruc='+ruc,winWidth*.75,winHeight*.65,null,null,'');
}
function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 1:msg='Corte Z';break;
		case 2:msg='Corte X';break;
		case 3:msg='Re-imprimir Facturas X Rango de Codigo';break;
		case 4:msg='Re-imprimir Facturas X Rango de Fecha';break;
		case 5:msg='Re-imprimir Facturas X RUC/CEDULA';break;
		case 6:msg='Listado de Facturas X Rango de numero';break;
		case 7:msg='Abrir Cajon';break;
		case 8:msg='Actualizar número fiscal';break;
	}
	setoverc(obj,'ImageBorderOver');
	optDescObj.innerHTML=msg;
	obj.alt=msg;
}
function mouseOut(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	setoutc(obj,'ImageBorder');
	optDescObj.innerHTML='&nbsp;';
}

function printList()
{
	abrir_ventana('../facturacion/print_list_docto_dgi.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbPrintListFilter.toString())%>',winWidth*.75,winHeight*.65,null,null,'');
}

$(window).bind('resize', function(){
		$('#list_opMain').css('width', '99%');
});

function showAsegList(){
 abrir_ventana1('../common/search_empresa.jsp?fp=docto_dgi');
}
</script>
<% if(touch.trim().equalsIgnoreCase("Y")) { %><link rel="stylesheet" href="../css/styles_touch.css" type="text/css"/><% } %>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INFORME_DE_VENTAS_1027"/>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
  <tr>
    <td align="right">&nbsp;<a href="javascript:printExcel()">[ Imprimir Excel ]</a></td>
  </tr>
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">

				<%
				fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("index",index)%>
				<%=fb.hidden("nt",nt)%>
				<%=fb.hidden("touch",touch)%>
				<tr class="TextFilter">
					<td>
					<cellbytelabel>No. Referencia</cellbytelabel>
					<%=fb.textBox("codigo",codigo,false,false,false,4,null,null,null)%>
					&nbsp;
					Cliente/Raz&oacute;n Social Receptor<%=fb.textBox("razon_social_rec",razon_social_rec,false,false,false,20,null,null,null)%>
					&nbsp;
					<cellbytelabel>Impreso</cellbytelabel>
					<%=fb.select("impreso","Y=Si, N=No",impreso,false,false,0, "text10", "", "", "", "S")%>
					&nbsp;
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="2" />
					<jsp:param name="clearOption" value="true" />
					<jsp:param name="nameOfTBox1" value="fecha_ini" />
					<jsp:param name="valueOfTBox1" value="<%=fecha_ini%>" />
					<jsp:param name="nameOfTBox2" value="fecha_fin" />
					<jsp:param name="valueOfTBox2" value="<%=fecha_fin%>" />
					</jsp:include>
					&nbsp;
					<%=fb.submit("go","Ir")%>
					</td>
				</tr>
				<%=fb.formEnd()%>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
<!--
<tr><td align="right"><authtype type='0'><a href="javascript:printList()" class="<%=touch.equalsIgnoreCase("Y")?"btn_red_link":"Link00"%>">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype></td></tr>
-->
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%
					fb = new FormBean("topPrevious",request.getContextPath()+request.getServletPath());
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("nt",nt)%>
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("razon_social_rec",""+razon_social_rec)%>
					<%=fb.hidden("tipo_doc",""+tipo_doc)%>
					<%=fb.hidden("impreso",""+impreso)%>
					<%=fb.hidden("fecha_ini",""+fecha_ini)%>
					<%=fb.hidden("fecha_fin",""+fecha_fin)%>
					<%=fb.hidden("ruc_receptor",""+ruc_receptor)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("touch",touch)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>

<%
fb = new FormBean("topNext",request.getContextPath()+request.getServletPath());
%>
					<%=fb.formStart()%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("nt",nt)%>
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("razon_social_rec",""+razon_social_rec)%>
					<%=fb.hidden("tipo_doc",""+tipo_doc)%>
					<%=fb.hidden("impreso",""+impreso)%>
					<%=fb.hidden("fecha_ini",""+fecha_ini)%>
					<%=fb.hidden("fecha_fin",""+fecha_fin)%>
					<%=fb.hidden("ruc_receptor",""+ruc_receptor)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("touch",touch)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("index","")%>

<tr width="100%">
	<td class="TableLeftBorder TableRightBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">


<table align="center" width="100%" cellpadding="<%=touch.trim().equalsIgnoreCase("Y")?"8":"0"%>" cellspacing="1" class="sortable" id="list">
	<tr class="TextHeader">
		<td width="9%"><cellbytelabel>Factura</cellbytelabel></td>
		<td width="3%"><cellbytelabel>Tipo Docto</cellbytelabel>.</td>
		<td width="6%"><cellbytelabel>Ref. de Factura</cellbytelabel></td>
		<td width="5%"><cellbytelabel>Fecha de Emisi&oacute;n</cellbytelabel></td>
		<td width="4%"><cellbytelabel>Tipo de Emisi&oacute;n</cellbytelabel></td>
		<td width="4%"><cellbytelabel>C&oacute;d. Sucursal</cellbytelabel></td>
		<td width="4%"><cellbytelabel>Punto de Facturaci&oacute;n</cellbytelabel></td>
		<td width="4%"><cellbytelabel>Tipo de Contribuyente</cellbytelabel></td>
		<td width="9%"><cellbytelabel>Ruc Emisor</cellbytelabel></td>
		<td width="3%"><cellbytelabel>DV Del Ruc</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Raz&oacute;n Social Emisor</cellbytelabel></td>
		<td width="4%"><cellbytelabel>Tipo Receptor</cellbytelabel></td>
		<td width="9%"><cellbytelabel>Ruc de Receptor</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Raz&oacute;n Social Receptor</cellbytelabel></td>
		<td width="9%"><cellbytelabel>ID Pasaporte</cellbytelabel></td>
		<td width="6%"><cellbytelabel>Pa&iacute;s del Receptor</cellbytelabel></td>
		<td width="6%"><cellbytelabel>Suma Items</cellbytelabel></td>
		<td width="6%"><cellbytelabel>ITBMS</cellbytelabel></td>
		<td width="6%"><cellbytelabel>Valor ISC</cellbytelabel></td>
		<td width="6%"><cellbytelabel>Total Impuestos</cellbytelabel></td>
		<td width="6%"><cellbytelabel>Total Factura</cellbytelabel></td>
		<td width="4%">&nbsp;</td>
	</tr>

	<%
	for (int i=0; i<al.size(); i++)
	{
	 CommonDataObject cdo = (CommonDataObject) al.get(i);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";

    %>
	<%=fb.hidden("id"+i,cdo.getColValue("id"))%>
	<%=fb.hidden("ruc_receptor"+i,cdo.getColValue("ruc_receptor"))%>
	<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
	<%=fb.hidden("tipo_docto"+i,cdo.getColValue("tipo_docto"))%>
	<%=fb.hidden("codigo_dgi"+i,cdo.getColValue("factura_dgi"))%>

	<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" >
		<td><%=cdo.getColValue("factura_dgi")%></td>
		<td><%=cdo.getColValue("tipo_doc")%></td>
        <td><%=cdo.getColValue("codigo")%></td>
		<td><%=cdo.getColValue("fecha")%></td>
		<td><%=cdo.getColValue("tipo_emision")%></td>
		<td><%=cdo.getColValue("cod_sucursal")%></td>
		<td><%=cdo.getColValue("punto_de_fact")%></td>
		<td><%=cdo.getColValue("tipo_de_contr")%></td>
		<td><%=cdo.getColValue("ruc_emisor")%></td>
		<td><%=cdo.getColValue("dv_emisor")%></td>
		<td><%=cdo.getColValue("razon_social_emi")%></td>
		<td><%=cdo.getColValue("tipo_receptor")%></td>
		<td><%=cdo.getColValue("ruc_receptor")%></td>
		<td><%=cdo.getColValue("razon_social_rec")%></td>
		<td><%=cdo.getColValue("id_pasaporte")%></td>
		<td><%=cdo.getColValue("pais_recep")%></td>
		<td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("sum_items"))%></td>
		<td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("itbms"))%></td>
		<td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("valor_isc"))%></td>
		<td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("t_impuestos"))%></td>
		<td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%></td>
		<td align="center"><authtype type='1'><a href="javascript:printFact(<%=i%>,'2')"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" src="../images/search.gif"></a></authtype></td>
	</tr>
	<%
	}
	%>

</table>

</div>
</div>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	</td>
</tr>
<%=fb.formEnd()%>

	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("nt",nt)%>
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("razon_social_rec",""+razon_social_rec)%>
					<%=fb.hidden("tipo_doc",""+tipo_doc)%>
					<%=fb.hidden("impreso",""+impreso)%>
					<%=fb.hidden("fecha_ini",""+fecha_ini)%>
					<%=fb.hidden("fecha_fin",""+fecha_fin)%>
					<%=fb.hidden("ruc_receptor",""+ruc_receptor)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("touch",touch)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>

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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("nt",nt)%>
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("razon_social_rec",""+razon_social_rec)%>
					<%=fb.hidden("tipo_doc",""+tipo_doc)%>
					<%=fb.hidden("impreso",""+impreso)%>
					<%=fb.hidden("fecha_ini",""+fecha_ini)%>
					<%=fb.hidden("fecha_fin",""+fecha_fin)%>
					<%=fb.hidden("ruc_receptor",""+ruc_receptor)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("touch",touch)%>
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