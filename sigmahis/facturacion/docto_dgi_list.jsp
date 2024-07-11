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
String tipo_docto = request.getParameter("tipo_docto");
String codigo = request.getParameter("codigo");
String paciente = request.getParameter("paciente");
String impreso = request.getParameter("impreso");
String num_impresora = request.getParameter("num_impresora");
String codigoDesde =request.getParameter("codigoDesde");
String codigoHasta =request.getParameter("codigoHasta");
String ruc_cedula =request.getParameter("rucCed");
String cod_caja =request.getParameter("cod_caja");
String usuario_factura =request.getParameter("usuario_factura");
String turno =request.getParameter("turno");
String codAseg =request.getParameter("cod_aseg");
String nombreAseg =request.getParameter("nombre_aseg");
String usuario =request.getParameter("usuario");
String touch = request.getParameter("touch") == null ? "" : request.getParameter("touch");

StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
StringBuffer sbPrintListFilter = new StringBuffer();

int iconHeight = touch.equalsIgnoreCase("y")?36:20;
int iconWidth = touch.equalsIgnoreCase("y")?36:20;
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
if(fecha_ini==null) fecha_ini = fecha;
if(fecha_fin==null) fecha_fin = fecha;
if(tipo_docto==null) tipo_docto = "";
if(codigo==null) codigo = "";
if(paciente==null) paciente = "";
if(num_impresora==null) num_impresora = "";
if(impreso==null) impreso = "N";
if(ruc_cedula==null) ruc_cedula = "";
if(codigoDesde==null) codigoDesde = "";
if(codigoHasta==null) codigoHasta = "";
if(cod_caja==null) cod_caja = "";
if(fp==null) fp = "";
if(fg==null) fg = "";
if(turno==null) turno = "";
if(codAseg==null) codAseg = "";
if(nombreAseg==null) nombreAseg = "";
if(usuario==null) usuario = "";
if(usuario_factura==null) usuario_factura = (String) session.getAttribute("_userName");
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
	if (!paciente.trim().equals("")){
		sbFilter.append(" and upper(a.cliente||decode(a.interfaz_far,'S',' - '||a.campo8,'')) like '%");
		sbFilter.append(paciente);
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
	if (!tipo_docto.trim().equals("")){
		sbFilter.append(" and tipo_docto = '");
		sbFilter.append(tipo_docto);
		sbFilter.append("'");
	}
	/*
	if (!impreso.trim().equals("")){
		sbFilter.append(" and nvl(impreso, 'N') = '");
		sbFilter.append(impreso);
		sbFilter.append("'");
	}
	*/
	if (!num_impresora.trim().equals("")){
		sbFilter.append(" and substr(codigo_dgi, 1, 14) like '");
		sbFilter.append(num_impresora);
		sbFilter.append("%'");
	}
	if (!ruc_cedula.trim().equals("")){
		sbFilter.append(" and a.ruc_cedula like '");
		sbFilter.append(ruc_cedula);
		sbFilter.append("%'");
	}
	if (!codigoDesde.trim().equals("")){
		sbFilter.append(" and decode(translate((substr(a.codigo_dgi,instr(a.codigo_dgi,'-') + 1)),'T 0123456789','T'),null,to_number(substr(a.codigo_dgi,instr(a.codigo_dgi,'-') + 1)),0) >= ");
		sbFilter.append(codigoDesde);
	}
	if (!codigoHasta.trim().equals("")){
		sbFilter.append(" and decode(translate((substr(a.codigo_dgi,instr(a.codigo_dgi,'-') + 1)),'T 0123456789','T'),null,to_number(substr(a.codigo_dgi,instr(a.codigo_dgi,'-') + 1)),0) <= ");
		sbFilter.append(codigoHasta);
	}

	if (!nombreAseg.trim().equals("")){
		sbFilter.append(" and a.campo4 like '%");
	sbFilter.append(nombreAseg);
		sbFilter.append("%'");
	}

	if(fp.equals("POS")){
		sbFilter.append(" and a.facturar_a = 'O' and tipo_docto in ('FACP', 'NCP', 'NDP')");
		if(!cod_caja.equals("")){
			sbFilter.append(" and exists (select null from tbl_fac_trx t where t.doc_id = a.cod_ref and t.cod_caja = ");
			sbFilter.append(cod_caja);
			if(!turno.equals("")){
				sbFilter.append(" and t.turno = ");
				sbFilter.append(turno);
			}
			sbFilter.append(")");
		}
	}

	if (!usuario_factura.trim().equals("")){
		sbFilter.append(" and usuario_creacion = '");
		sbFilter.append(usuario_factura);
		sbFilter.append("'");
	}


	sbPrintListFilter.append(sbFilter.toString());
		sbSql.append("select a.id, a.tipo_docto, a.compania, a.anio, a.codigo, (case when a.tipo_docto = 'FACT' then a.monto-nvl((select sum(monto) from tbl_fac_detalle_factura f where f.compania = a.compania and f.fac_codigo = a.codigo and exists (select null from tbl_cds_centro_servicio cds where cds.codigo = f.centro_servicio and cds.tipo_cds = 'T' and cds.codigo != 0)), 0) else a.monto end) monto, a.impuesto, a.descuento, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.usuario_creacion, a.fecha_creacion, a.cod_ref, a.tipo_docto_ref, a.cliente||decode(interfaz_far,'S',' - '||campo8,'') as cliente, a.identificacion, nvl(a.impreso, 'N') impreso, a.codigo_dgi, a.campo1, a.campo2, a.campo3, a.campo4, a.campo5, a.campo6, a.campo7, a.dv, a.ruc_cedula, to_char(nvl(a.fecha_impresion,impresion_timestamp), 'dd/mm/yyyy hh12:mi:ss am') fecha_impresion,nvl((select count(*) from tbl_fac_factura f where f.codigo = a.codigo and f.compania = a.compania and a.tipo_docto ='FACT' and f.estatus = 'A'),0) anulada, nvl(substr(a.impresion_webuser_ip,0,instr(a.impresion_webuser_ip,':') - 1),' ') as impreso_por, decode(nvl(a.impreso,'N'),'N',' ',case when a.tipo_docto in ('NC','ND') then (select codigo_dgi from tbl_fac_dgi_documents where tipo_docto = 'FACT' and cod_ref = a.cod_ref) when a.tipo_docto in ('FACP','FACT') then ' ' else a.cod_ref end) as codigo_dgi_ref from tbl_fac_dgi_documents a where a.compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
	if (!impreso.trim().equals("")){
		sbSql.append(" and nvl(impreso, 'N') = '");
		sbSql.append(impreso);
		sbSql.append("'");
		sbPrintListFilter.append(" and nvl(impreso, 'N') = '");
		sbPrintListFilter.append(impreso);
		sbPrintListFilter.append("'");
	}

		sbSql.append(sbFilter.toString());

		if (impreso.trim().equals("N"))sbSql.append(" and not exists (select 1 from tbl_fac_factura f where f.codigo = a.codigo and f.compania = a.compania and a.tipo_docto = 'FACT' and f.estatus = 'A')");
		
		if (!usuario.trim().equals("")){
			sbSql.append(" and exists (select 1 from tbl_fac_factura f where f.codigo = a.codigo and f.compania = a.compania and a.tipo_docto = 'FACT' and f.estatus != 'A' and upper(f.usuario_creacion) = '");
			sbSql.append(usuario.toUpperCase());
			sbSql.append("')");
		}

		sbSql.append(" order by a.fecha desc, nvl(a.fecha_impresion,impresion_timestamp) desc");
		if (impreso.trim().equals("N"))sbPrintListFilter.append(" and not exists (select 1 from tbl_fac_factura f where f.codigo = a.codigo and f.compania = a.compania and a.tipo_docto = 'FACT' and f.estatus = 'A')");
		
		if (!usuario.trim().equals("")){
			sbPrintListFilter.append(" and exists (select 1 from tbl_fac_factura f where f.codigo = a.codigo and f.compania = a.compania and a.tipo_docto = 'FACT' and f.estatus != 'A' and upper(f.usuario_creacion) = '");
			sbPrintListFilter.append(usuario.toUpperCase());
			sbPrintListFilter.append("')");
		}

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
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Facturas - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function printFact(i, flag)
{
	var id = eval('document.form0.id'+i).value;
	var codigo = eval('document.form0.codigo'+i).value;
	var tipo_docto = eval('document.form0.tipo_docto'+i).value;
	var ruc = eval('document.form0.ruc_cedula'+i).value;
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
{    var tipo_docto = document.search01.tipo_docto.value;
	//var ruc = eval('document.search01.ruc_cedula').value;
	var codigoDesde = document.search01.codigoDesde.value;
	var codigoHasta = document.search01.codigoHasta.value;
	var fechaDesde = document.search01.fechaDesde.value;
	var fechaHasta = document.search01.fechaHasta.value;
	var rucCed = document.search01.rucCed.value;
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


}

function printDoct(i)
{
	var id = eval('document.form0.id'+i).value;
	var codigo = eval('document.form0.codigo'+i).value;
	var tipo_docto = eval('document.form0.tipo_docto'+i).value;
	var ruc = eval('document.form0.ruc_cedula'+i).value;
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
function corregirDgi(i)
{
	var id = eval('document.form0.id'+i).value;
	var codigo = eval('document.form0.codigo'+i).value;
	var tipo_docto = eval('document.form0.tipo_docto'+i).value;
	var codigoDgi = eval('document.form0.codigo_dgi'+i).value;
	showPopWin('../common/run_process.jsp?fp=docto_dgi_list&actType=52&docType=DGI'+'&docNo='+codigo+'&tipo='+tipo_docto+'&docId='+id+'&codigoDgi='+codigoDgi+'&impresoSi=<%=p.getColValue("impresoSi")%>',winWidth*.75,winHeight*.65,null,null,'');
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
	<jsp:param name="title" value="FACTURAS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
	<tr>
		<td align="right">
		<div id="optDesc" class="TextInfo Text10">&nbsp;</div>
		<authtype type='50'>
		<a href="javascript:goOption(1)"><img height="<%=iconHeight+10%>" width="<%=iconWidth+10%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/printer_z.gif"></a></authtype>
		<authtype type='51'><a href="javascript:goOption(2)"><img height="<%=iconHeight+10%>" width="<%=iconWidth+10%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/printer_x.gif"></a></authtype>
		<!--<authtype type='55'><a href="javascript:goOption(3)"><img height="<%=iconHeight+10%>" width="<%=iconWidth+10%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/printer.gif"></a></authtype>
		<authtype type='56'><a href="javascript:goOption(4)"><img height="<%=iconHeight+10%>" width="<%=iconWidth+10%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,4)" onMouseOut="javascript:mouseOut(this,4)" src="../images/printer.gif"></a></authtype>
		<authtype type='57'><a href="javascript:goOption(5)"><img height="<%=iconHeight+10%>" width="<%=iconWidth+10%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,5)" onMouseOut="javascript:mouseOut(this,5)" src="../images/printer.gif"></a></authtype>
		<!--<authtype type='58'><a href="javascript:goOption(6)"><img height="<%=iconHeight+10%>" width="<%=iconWidth+10%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,6)" onMouseOut="javascript:mouseOut(this,6)" src="../images/printer.gif"></a></authtype>
		<authtype type='59'><a href="javascript:goOption(7)"><img height="<%=iconHeight+10%>" width="<%=iconWidth+10%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,7)" onMouseOut="javascript:mouseOut(this,7)" src="../images/icons/_cashregister48.png"></a></authtype>-->
		</td>
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
				<%=fb.hidden("turno",turno)%>
				<%=fb.hidden("touch",touch)%>
				<tr class="TextFilter">
					<td>
					<cellbytelabel>No. Referencia</cellbytelabel>
					<%=fb.textBox("codigo",codigo,false,false,false,4,null,null,null)%>
					Cliente<%=fb.textBox("paciente",paciente,false,false,false,20,null,null,null)%>
					&nbsp;
					<cellbytelabel>Impresora</cellbytelabel>:
					<%=fb.textBox("num_impresora",num_impresora,false,false,false,4,null,null,null)%>
					&nbsp;
					<cellbytelabel>Tipo Docto</cellbytelabel>.
					<%=fb.select("tipo_docto",(fp.equals("POS")?"FACP=Factura, NCP=Nota de Credito, NDP=Nota de Debito":"FACT=Factura, NC=Nota de Credito, ND=Nota de Debito"),tipo_docto,"S")%>
					&nbsp;
					<cellbytelabel>Impreso</cellbytelabel>
					<%=fb.select("impreso","Y=Si, N=No",impreso,"")%>
					&nbsp;
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="2" />
					<jsp:param name="clearOption" value="true" />
					<jsp:param name="nameOfTBox1" value="fecha_ini" />
					<jsp:param name="valueOfTBox1" value="<%=fecha_ini%>" />
					<jsp:param name="nameOfTBox2" value="fecha_fin" />
					<jsp:param name="valueOfTBox2" value="<%=fecha_fin%>" />
					</jsp:include>
					</td>
				</tr>
				<tr class="TextFilter">
					<td colspan="1"><cellbytelabel>#Fiscal Desde</cellbytelabel>
					<%=fb.textBox("codigoDesde",codigoDesde,false,false,false,8,null,null,null)%>
					<cellbytelabel>Hasta</cellbytelabel> <%=fb.textBox("codigoHasta",codigoHasta,false,false,false,12,null,null,null)%>
					&nbsp;
					<cellbytelabel>Caja</cellbytelabel>:
					<%=fb.select(ConMgr.getConnection(),sbCaja.toString(),"cod_caja",cod_caja,false,false,0, "text10", "", "", "", "S")%>
					&nbsp;
					<cellbytelabel>RUC</cellbytelabel>/Cedula:<%=fb.textBox("rucCed",ruc_cedula,false,false,false,12,null,null,null)%>
					Fecha (Para Corte Z/X ) Desde <%=fb.textBox("fechaDesde","",false,false,false,8,null,null,null)%>
					<cellbytelabel>Hasta</cellbytelabel> <%=fb.textBox("fechaHasta","",false,false,false,12,null,null,null)%>
					</td>
				</tr>
				<tr class="TextFilter">
					<td colspan="1"><cellbytelabel>Usuario Cajero:</cellbytelabel>
					<%=fb.select(ConMgr.getConnection(),sbUsuario.toString(),"usuario_factura",usuario_factura,false,false,0, "text10", "", "", "", "S")%>&nbsp;&nbsp;Aseguradora:

										<%=fb.intBox("cod_aseg",codAseg,false,false,true,5)%>
					<%=fb.textBox("nombre_aseg",nombreAseg,false,false,true,30)%>
					Usuario Factura:
					<%=fb.textBox("usuario",usuario,false,false,false,30)%>
					
										<%=fb.button("btnPaciente","...",true,false,null,null,"onClick=\"javascript:showAsegList()\"")%>
					&nbsp;&nbsp;<%=fb.submit("go","Ir")%>
					</td>
				</tr>
				<%=fb.formEnd()%>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
<tr><td align="right"><authtype type='0'><a href="javascript:printList()" class="<%=touch.equalsIgnoreCase("Y")?"btn_red_link":"Link00"%>">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype></td></tr>

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
					<%=fb.hidden("paciente",""+paciente)%>
					<%=fb.hidden("tipo_docto",""+tipo_docto)%>
					<%=fb.hidden("impreso",""+impreso)%>
					<%=fb.hidden("fecha_ini",""+fecha_ini)%>
					<%=fb.hidden("fecha_fin",""+fecha_fin)%>
					<%=fb.hidden("num_impresora",""+num_impresora)%>
					<%=fb.hidden("rucCed",""+ruc_cedula)%>
					<%=fb.hidden("codigoDesde",""+codigoDesde)%>
					<%=fb.hidden("codigoHasta",""+codigoHasta)%>
					<%=fb.hidden("cod_caja",""+cod_caja)%>
					<%=fb.hidden("usuario_factura",""+usuario_factura)%>
					<%=fb.hidden("usuario",""+usuario)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("turno",turno)%>
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
					<%=fb.hidden("paciente",""+paciente)%>
					<%=fb.hidden("tipo_docto",""+tipo_docto)%>
					<%=fb.hidden("impreso",""+impreso)%>
					<%=fb.hidden("fecha_ini",""+fecha_ini)%>
					<%=fb.hidden("fecha_fin",""+fecha_fin)%>
					<%=fb.hidden("num_impresora",""+num_impresora)%>
					<%=fb.hidden("rucCed",""+ruc_cedula)%>
					<%=fb.hidden("codigoDesde",""+codigoDesde)%>
					<%=fb.hidden("codigoHasta",""+codigoHasta)%>
					<%=fb.hidden("cod_caja",""+cod_caja)%>
					<%=fb.hidden("usuario_factura",""+usuario_factura)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("turno",turno)%>
				<%=fb.hidden("touch",touch)%>
					<%=fb.hidden("usuario",""+usuario)%>
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
		<td width="10%"><cellbytelabel>C&oacute;digo DGI</cellbytelabel></td>
		<td width="5%" align="center"><cellbytelabel>Corregir</cellbytelabel></td>
		<td width="8%"><cellbytelabel>Referencia</cellbytelabel></td>
		<td width="6%"><cellbytelabel>Fecha</cellbytelabel></td>
		<td width="4%"><cellbytelabel>Tipo Docto</cellbytelabel>.</td>
		<td width="10%"><cellbytelabel>C&oacute;digo DGI Ref</cellbytelabel>.</td>
		<td width="15%"><cellbytelabel>Cliente</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Identificaci&oacute;n</cellbytelabel></td>
		<td width="8%" align="right"><cellbytelabel>Monto</cellbytelabel></td>
		<td width="8%" align="center"><cellbytelabel>Impreso Por</cellbytelabel></td>
		<td width="8%" align="center"><cellbytelabel>Fecha Impr</cellbytelabel>.</td>
		<td width="4%">&nbsp;</td>
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
	<%=fb.hidden("ruc_cedula"+i,cdo.getColValue("ruc_cedula"))%>
	<%=fb.hidden("dv"+i,cdo.getColValue("dv"))%>
	<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
	<%=fb.hidden("tipo_docto"+i,cdo.getColValue("tipo_docto"))%>
	<%=fb.hidden("codigo_dgi"+i,cdo.getColValue("codigo_dgi"))%>


	<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" >
		<td><%=cdo.getColValue("codigo_dgi")%></td>
		<td align="center"><%/*if(cdo.getColValue("anulada")!=null && cdo.getColValue("anulada").trim().equals("0")){*/%><authtype type='52'>
		<a href="javascript:corregirDgi(<%=i%>)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" src="../images/actualizar.gif"></a></authtype><%/*}*/%>
		</td>
<td><%=cdo.getColValue("codigo")%></td>
		<td><%=cdo.getColValue("fecha")%></td>
		<td><%=cdo.getColValue("tipo_docto")%></td>
		<td><%=cdo.getColValue("codigo_dgi_ref")%></td>
		<td><%=cdo.getColValue("cliente")%></td>
		<td><%=cdo.getColValue("identificacion")%></td>
		<td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%></td>
		<td align="center"><%=cdo.getColValue("impreso_por")%></td>
		<td align="center"><%=cdo.getColValue("fecha_impresion")%></td>
		<td align="center">
		<%if(cdo.getColValue("impreso")!=null && cdo.getColValue("impreso").trim().equals("N")&&cdo.getColValue("anulada")!=null && cdo.getColValue("anulada").trim().equals("0")){%>
		<authtype type='53'><a href="javascript:printFact(<%=i%>,'1')"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" src="../images/printer.gif"></a></authtype>
		<%}else if(cdo.getColValue("impreso")!=null && cdo.getColValue("impreso").trim().equals("Y")){%>
		<authtype type='54'>
		<a href="javascript:printFact(<%=i%>,'5')"><img height="<%=iconHeight+10%>" width="<%=iconWidth+10%>" class="ImageBorder" src="../images/imprimir_copia.png" alt="Reimprimir"></a></authtype>

		<%}%>
		</td>

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
					<%=fb.hidden("paciente",""+paciente)%>
					<%=fb.hidden("tipo_docto",""+tipo_docto)%>
					<%=fb.hidden("impreso",""+impreso)%>
					<%=fb.hidden("fecha_ini",""+fecha_ini)%>
					<%=fb.hidden("fecha_fin",""+fecha_fin)%>
					<%=fb.hidden("num_impresora",""+num_impresora)%>
					<%=fb.hidden("rucCed",""+ruc_cedula)%>
					<%=fb.hidden("codigoDesde",""+codigoDesde)%>
					<%=fb.hidden("codigoHasta",""+codigoHasta)%>
					<%=fb.hidden("cod_caja",""+cod_caja)%>
					<%=fb.hidden("usuario_factura",""+usuario_factura)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("turno",turno)%>
				<%=fb.hidden("touch",touch)%>
					<%=fb.hidden("usuario",""+usuario)%>
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
					<%=fb.hidden("paciente",""+paciente)%>
					<%=fb.hidden("tipo_docto",""+tipo_docto)%>
					<%=fb.hidden("impreso",""+impreso)%>
					<%=fb.hidden("fecha_ini",""+fecha_ini)%>
					<%=fb.hidden("fecha_fin",""+fecha_fin)%>
					<%=fb.hidden("num_impresora",""+num_impresora)%>
					<%=fb.hidden("rucCed",""+ruc_cedula)%>
					<%=fb.hidden("codigoDesde",""+codigoDesde)%>
					<%=fb.hidden("codigoHasta",""+codigoHasta)%>
					<%=fb.hidden("cod_caja",""+cod_caja)%>
					<%=fb.hidden("usuario_factura",""+usuario_factura)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("turno",turno)%>
				<%=fb.hidden("touch",touch)%>
					<%=fb.hidden("usuario",""+usuario)%>
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