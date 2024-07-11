<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql= new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fg = request.getParameter("fg");
int iconHeight = 40;
int iconWidth = 40;

if (fg == null) fg = "AFA";

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

	String codigo = request.getParameter("codigo");
	String secuencia = request.getParameter("secuencia");
	String nombre = request.getParameter("nombre");
	String factura = request.getParameter("factura");
	String fDate = request.getParameter("fDate");
	String tDate = request.getParameter("tDate");
	String facturar_a = request.getParameter("facturar_a");
	String fechaNac = request.getParameter("fechaNac");
	String aseguradora = request.getParameter("aseguradora");
	String aseguradoraDesc = request.getParameter("aseguradoraDesc");
	String estado = request.getParameter("estado");
	String tipoRef = request.getParameter("tipoRef");
	String refId = request.getParameter("refId");
	String rechazadas =  request.getParameter("rechazadas");

	if (codigo == null) codigo = "";
	if (secuencia == null) secuencia = "";
	if (nombre == null) nombre = "";
	if (factura == null) factura = "";
	if (fDate == null) fDate = "";
	if (tDate == null) tDate = "";
	if (facturar_a == null) facturar_a = "";
	if (fechaNac == null) fechaNac = "";
	if (aseguradora == null) aseguradora = "";
	if (aseguradoraDesc == null) aseguradoraDesc = "";
	if (estado == null) estado = "";
	if (tipoRef == null) tipoRef = "";
	if (refId == null) refId = "";
	if (rechazadas == null) rechazadas = "";

	if (!codigo.trim().equals("")) { sbFilter.append(" and a.pac_id like '%"); sbFilter.append(codigo); sbFilter.append("%'"); }
	if (!secuencia.trim().equals("")) { sbFilter.append(" and a.admi_secuencia like '%"); sbFilter.append(secuencia); sbFilter.append("%'"); }
	if (!nombre.trim().equals("")) {
		if (fg.equalsIgnoreCase("POS")) {
			if (facturar_a.equalsIgnoreCase("P")) {
				sbFilter.append(" and exists (select null from vw_adm_paciente where pac_id = a.pac_id and upper(nombre_paciente) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%')");
			} else {
				sbFilter.append(" and upper(a.nombre_cliente) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'");
			}
		} else {
			sbFilter.append(" and (exists (select null from vw_adm_paciente where pac_id = a.pac_id and upper(nombre_paciente) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%') or upper(a.nombre_cliente) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%')");
		}
	}
	if (!factura.trim().equals("")) { sbFilter.append(" and upper(a.codigo) like '%"); sbFilter.append(factura.toUpperCase()); sbFilter.append("%'"); }
	if (!fDate.trim().equals("")) { sbFilter.append(" and a.fecha >= to_date('"); sbFilter.append(fDate); sbFilter.append("','dd/mm/yyyy')"); }
	if (!tDate.trim().equals("")) { sbFilter.append(" and a.fecha <= to_date('"); sbFilter.append(tDate); sbFilter.append("','dd/mm/yyyy')"); }
	if (!facturar_a.trim().equals("")) {
		sbFilter.append(" and a.facturar_a = '"); sbFilter.append(facturar_a); sbFilter.append("'");
	}
	
	if (!fechaNac.trim().equals("")) { sbFilter.append(" and exists (select null from vw_adm_paciente where pac_id = a.pac_id and trunc(f_nac) = to_date('"); sbFilter.append(fechaNac); sbFilter.append("','dd/mm/yyyy'))"); }
	if (!aseguradora.trim().equals("")) { sbFilter.append(" and a.cod_empresa = "); sbFilter.append(aseguradora); }
	if (!estado.trim().equals("")) { sbFilter.append(" and a.estatus = '"); sbFilter.append(estado); sbFilter.append("'"); }
	if (!refId.trim().equals("")) { sbFilter.append(" and (a.cod_otro_cliente = '"); sbFilter.append(refId.toUpperCase()); sbFilter.append("'"); }
	if (!tipoRef.trim().equals("")) { sbFilter.append(" and (a.cliente_otros = "); sbFilter.append(tipoRef); } //Esta condicion termina abajo Ojo
	
	
	if (!tipoRef.trim().equals("")) sbFilter.append(")");//Ojo aqui termina la condicion de tipoRef
	if (!refId.trim().equals("")) {sbFilter.append(") ");}
	if (request.getParameter("nombre") != null) {

		if (fg.equalsIgnoreCase("POS")) {

			sbSql.append("select distinct decode(a.facturar_a,'O',trim(a.nombre_cliente),'E',(select nombre from tbl_adm_empresa where codigo = a.cod_empresa),(select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id)) as nombre, a.cliente_otros as ref_type, cod_otro_cliente as ref_id, (select refer_to from tbl_fac_tipo_cliente where codigo = a.cliente_otros and compania = a.compania) as referTo, (select descripcion from tbl_fac_tipo_cliente where codigo = a.cliente_otros and compania = a.compania) as referDesc from tbl_fac_factura a where a.estatus <> 'A' and  a.compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(sbFilter);

			sbSql.append(" order by 1");

		} else {
			sbSql.append("select x.*,(case when nvl(saldo,0) > 0 then 'N' else 'S' end) puede_cancelar  from (select a.codigo as cod_factura, a.f_anio, a.numero_factura, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.tipo, a.estatus, a.grang_total, a.admi_codigo_paciente as codigo,a.admi_secuencia, a.pac_id, a.cod_empresa, decode(a.facturar_a,'P','Paciente','E','Empresa','O','Otros') as tipo_factura, to_char(a.admi_fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, a.admi_codigo_paciente, a.cliente_otros as ref_type, cod_otro_cliente as ref_id, decode(comentario,'S/I','S','N') saldoInicial, decode(a.estatus,'A','ANULADA','P','PENDIENTE','C','CANCELADA') as estatusDesc, a.lista, a.tipo_cobertura, a.compania, a.facturar_a, a.nombre_cliente /**************/, decode(a.facturar_a,'O',a.nombre_cliente,(select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id)) as nombre, (select d.nombre from tbl_adm_empresa d where d.codigo = a.cod_empresa) as nombre_empresa,'' as facImpresa, '' as ref_dgi, (select refer_to from tbl_fac_tipo_cliente where codigo = a.cliente_otros and compania = a.compania) as referTo, fn_cja_saldo_fact(a.facturar_a, a.compania,a.codigo,a.grang_total) as saldo, nvl((select sum(monto) from tbl_cja_distribuir_pago  dp, tbl_cja_transaccion_pago tp  where dp.fac_codigo = a.codigo and dp.compania = a.compania and tp.codigo=dp.codigo_transaccion and tp.compania=dp.compania and tp.anio=dp.tran_anio and tp.rec_status <> 'I' ),0) as monto_dist, get_fac_pagos_fac(a.codigo, a.compania) pagado,(select to_char(f_nac,'dd/mm/yyyy') from vw_adm_paciente where pac_id = a.pac_id) as f_nac from tbl_fac_factura a where a.compania =");
			sbSql.append((String)session.getAttribute("_companyId"));
			sbSql.append(sbFilter);
			sbSql.append(" and estatus <> 'A' and facturar_a ='E') x where saldo > 0 ");
			if(rechazadas.trim().equals(""))sbSql.append(" and (saldo < decode(grang_total,0,saldo+1, grang_total))");
			else sbSql.append(" and saldo = grang_total ");
			sbSql.append(" order by f_anio desc, numero_factura desc");
		}

		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) count from ("+sbSql+")");

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
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<link href="../css/select2.css" rel="stylesheet"/>
<script src="../js/select2.min.js"></script>
<script>
document.title = 'Facturacion - '+document.title;
var gTitleAlert = '<%=java.util.ResourceBundle.getBundle("issi").getString("windowTitle")%>';
function printList(){
	var rechazadas = '';
	if(document.search01.rechazadas)rechazadas=(document.search01.rechazadas.checked?"S":"");
	var aseguradora = getSelectedOptionLabel(document.search01.aseguradora, '');
	abrir_ventana('../facturacion/print_list_ajuste_automatico.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>&fg=<%=fg%>&rechazadas='+rechazadas+'&aseguradora='+aseguradora);
}
function showEmpresaList(){abrir_ventana1('../common/search_empresa.jsp?fp=consFact');}
function setIndex(k){document.form0.index.value=k;checkOne('form0','check',<%=al.size()%>,eval('document.form0.check'+k),0);}
function mouseOut(obj,option){var optDescObj=document.getElementById('optDesc');setoutc(obj,'ImageBorder');optDescObj.innerHTML='&nbsp;';}
function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
	case 0:msg='Registrar Analisis';break;
	case 1:msg='Anular Factura';break;
	case 2:msg='Estado de Cuenta detallado por factura';break;
	case 3:msg='Ajustes Por Cargo tardio(Detallado)';break;
	case 4:msg='Imprimir Factura Pre - Impresa';break;
	case 5:msg='Imprimir Factura';break;
	case 6:msg='Ajustes Devolucion(Detallado)';break;
	case 7:msg='Ajustes Por Cargo tardio';break;
	case 8:msg='Ajuste Devolución';break;
	case 9:msg='Ajustes Por Cargo tardio(Honorarios)';break;
	case 10:msg='Ajuste Devolución (Honorarios)';break;
	case 11:msg='Otros Ajustes Factura (Descuentos)';break;
	case 12:msg='Cambio de Estado de Factura';break;
	case 13:msg='Consulta General de Admisiones';break;
	case 14:msg='Imprimir Analisis';break;
	case 15:msg='Ver Analisis';break;
	case 16:msg='Estado de Cuenta';break;
	case 17:msg='Ver Factura';break;
	case 18:msg='Ajustes a Facturas Doble Cobertura';break;
	case 19:msg='Imprimir Detalles de Cargos';break;
	case 20:msg='Imprimir Detalles de Cargos Netos';break;
	case 21:msg='Anular Factura(Impresa Fiscal)';break;
	case 22:msg='Ajustes Correccion Fiscal POS';break;

	}
	setoverc(obj,'ImageBorderOver');
	optDescObj.innerHTML=msg;
	obj.alt=msg;
}
function goOption(option)
{
	if(option==0)abrir_ventana('../facturacion/reg_analisis_fact.jsp?mode=add&fg=<%=fg%>');
	else{
	if(option==undefined)CBMSG.warning('La opción no está definida todavía.\nPor favor consulte con su Administrador!');
	else
	{
		var k=document.form0.index.value;
		if(k=='')CBMSG.warning('Por favor seleccione una factura antes de ejecutar una acción!');
		else
		{
			var compania = eval('document.form0.compania'+k).value ;
			var factura = eval('document.form0.factura'+k).value;
			var tipo_cob = eval('document.form0.tipo_cob'+k).value;
			var pacId = eval('document.form0.pacId'+k).value ;
			var noAdmision = eval('document.form0.noAdmision'+k).value;
			var status = eval('document.form0.status'+k).value;
			var facturar_a = eval('document.form0.facturar_a'+k).value;
			var facImpresa = eval('document.form0.facImpresa'+k).value;
			var refDgi = eval('document.form0.ref_dgi'+k).value;
			var ref_type = eval('document.form0.ref_type'+k).value;
			var ref_id = eval('document.form0.ref_id'+k).value;
			var referTo = eval('document.form0.referTo'+k).value;
			var si = eval('document.form0.si'+k).value;
			
			if(facturar_a !='O'||option==16||option==11||option==17||option==22){
			if((option!=2 &&option!=4&&option!=5&&option!=13&&option!=14&&option!=16&&option!=17&&option!=19&&option!=20) && status=='A')CBMSG.warning('El Estado de la Factura no permite esta Accion!!!');
			else if(option==1)if(facturar_a !='O'){if(facImpresa!='0'){CBMSG.warning('La factura a anular ya fue impresa Fiscalmente.\n Favor Solicitarle a su supervisor la anulacion.');}				else{ showPopWin('../common/run_process.jsp?fp=factura&actType=7&docType=FACT&docId='+factura+'&docNo='+factura+'&compania='+compania+'&tipoCob='+tipo_cob+'&pacId='+pacId+'&noAdmision='+noAdmision,winWidth*.75,winHeight*.65,null,null,'');}}else CBMSG.warning('Solo para Facturas de Pacientes Y Empresas');
			else if(option==21)if(facturar_a !='O'){if(facImpresa!='0'){CBMSG.warning('La factura a anular ya fue impresa Fiscalmente.\n Favor revisar e Imprimir su Respecitva nota de Credito.');} showPopWin('../common/run_process.jsp?fp=factura&actType=7&docType=FACT&docId='+factura+'&docNo='+factura+'&compania='+compania+'&tipoCob='+tipo_cob+'&pacId='+pacId+'&noAdmision='+noAdmision,winWidth*.75,winHeight*.65,null,null,'');}else CBMSG.warning('Solo para Facturas de Pacientes Y Empresas');
			else if(option==2)abrir_ventana1('../facturacion/print_estado_cargo_det.jsp?factId='+factura+'&pacId='+pacId);
			else if(option==3)abrir_ventana1('../facturacion/reg_ajuste_factura.jsp?fg=CARGO&factura='+factura+'&pacId='+pacId+'&noAdmision='+noAdmision+'&ref_type='+ref_type+'&ref_id='+ref_id);
			else if(option==4)abrir_ventana1('../facturacion/print_fact.jsp?factura='+factura+'&compania='+compania);
			else if(option==5)abrir_ventana1('../facturacion/print_factura.jsp?factura='+factura+'&compania='+compania);
			else if(option==6)abrir_ventana1('../facturacion/reg_ajuste_factura.jsp?fg=DEV&factura='+factura+'&pacId='+pacId+'&noAdmision='+noAdmision+'&ref_type='+ref_type+'&ref_id='+ref_id);
			else if(option==7)if(parseInt(noAdmision)>0)abrir_ventana1('../facturacion/notas_ajuste_cargo_dev.jsp?pacienteId='+pacId+'&noAdmision='+noAdmision+'&factura='+factura+'&nt=C&fg=C&tr=RE&ref_type='+ref_type+'&ref_id='+ref_id);else CBMSG.warning('OPCION INVALIDA PARA FACTURAS DE SALDO INICIAL');
			else if(option==8)if(parseInt(noAdmision)>0)abrir_ventana1('../facturacion/notas_ajuste_cargo_dev.jsp?pacienteId='+pacId+'&noAdmision='+noAdmision+'&factura='+factura+'&nt=D&fg=D&tr=RE&ref_type='+ref_type+'&ref_id='+ref_id);else CBMSG.warning('OPCION INVALIDA PARA FACTURAS DE SALDO INICIAL');
			else if(option==9)if(parseInt(noAdmision)>0)abrir_ventana1('../facturacion/notas_ajuste_cargo_dev.jsp?pacienteId='+pacId+'&noAdmision='+noAdmision+'&factura='+factura+'&nt=H&fg=C&tr=RE&ref_type='+ref_type+'&ref_id='+ref_id);else CBMSG.warning('OPCION INVALIDA PARA FACTURAS DE SALDO INICIAL');
			else if(option==10)if(parseInt(noAdmision)>0)abrir_ventana1('../facturacion/notas_ajuste_cargo_dev.jsp?pacienteId='+pacId+'&noAdmision='+noAdmision+'&factura='+factura+'&nt=H&fg=D&tr=RE&ref_type='+ref_type+'&ref_id='+ref_id);else CBMSG.warning('OPCION INVALIDA PARA FACTURAS DE SALDO INICIAL');
			else if(option==11){
				if(facturar_a=='O' && si!='S') abrir_ventana1('../pos/notas_ajustes_otros.jsp?codigo='+factura+'&ref_type='+ref_type+'&ref_id='+ref_id);
				else abrir_ventana1('../facturacion/notas_ajustes_config.jsp?fg=AF&fp=notas&isAjusteAut=Y&factura='+factura+'&ref_type='+ref_type+'&ref_id='+ref_id);}
			else if(option==12){var estado ='';var ubicacion ='';if(status == "P"){estado ='C';ubic = 'COBROS';}else if(status == "C"){estado ='P';ubicacion = 'ANALISIS';} if(status=='P' && eval('document.form0.puede_cancelar'+k).value=='N')CBMSG.warning('No puede Cancelar una Factura con Saldo!'); else showPopWin('../common/run_process.jsp?fp=UPDFACT&actType=50&docType=UPDFACT&estado='+estado+'&ubicacion='+ubicacion+'&docNo='+factura+'&compania='+compania,winWidth*.75,winHeight*.65,null,null,'');}
			else if(option==13){abrir_ventana('../admision/consulta_general.jsp?mode=view&pacId='+pacId+'&noAdmision='+noAdmision);}
			else if(option==14) abrir_ventana1('../facturacion/print_cargo_dev_resumen2.jsp?noSecuencia='+noAdmision+'&pacId='+pacId+'&tf=');
			else if(option==15) abrir_ventana1('../facturacion/reg_facturacion_manual.jsp?noAdmision='+noAdmision+'&pacId='+pacId+'&mode=view');
			else if(option==16)printRFP(ref_id,ref_type,referTo);
			else if(option==17)showDgi(refDgi);
			else if(option==18)if(facturar_a =='E'){abrir_ventana1('../cxc/ajuste_automatico_config.jsp?noAdmision='+noAdmision+'&pacienteId='+pacId+'&factura='+factura);}else CBMSG.warning('La factura seleccionada no Aplica para este Proceso!!!!');
			else if(option==19){if(facturar_a !='O'){abrir_ventana('../facturacion/print_cargo_dev.jsp?noSecuencia='+noAdmision+'&pacId='+pacId);}}
			else if(option==20){if(facturar_a !='O'){abrir_ventana('../facturacion/print_cargo_dev_neto.jsp?noSecuencia='+noAdmision+'&pacId='+pacId);}}
			else if(option==22){if(facturar_a =='O'){abrir_ventana1('../facturacion/notas_ajustes_config.jsp?fp=POS&fg=AF&factura='+factura+'&ref_type='+ref_type+'&ref_id='+ref_id);}}

			}else CBMSG.warning('Opciones Solo para Facturas de Pacientes y Empresas');
		}
	}
	}
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}
function showDetail(factura){showPopWin('../common/factura_detalle.jsp?factura='+factura,winWidth*.75,winHeight*.65,null,null,'');}
function showDgi(ref_dgi){showPopWin('../facturacion/ver_impresion_dgi.jsp?docId='+ref_dgi,winWidth*.75,winHeight*.65,null,null,'');}
<!-- W I N D O W S -->
//Windows Size and Position
var _winWidth=screen.availWidth*0.35;
var _winHeight=screen.availHeight*0.35;
var _winPosX=(screen.availWidth-_winWidth)/2;
var _winPosY=(screen.availHeight-_winHeight)/2;
var _popUpOptions='toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width='+_winWidth+',height='+_winHeight+',top='+_winPosY+',left='+_winPosX;
function printRFP(refId,refType,referTo)
{
	var val = '../common/sel_periodo.jsp?fg=FACT&refId='+refId+'&refType='+refType+'&referTo='+referTo;
	if(refId!='')	window.open(val,'datesWindow',_popUpOptions);
	else CBMSG.warning('El cliente seleccionado no tiene referencia!!!');
}

$(document).ready(function() { 
  $("#aseguradora").select2({formatNoMatches:function(){
     return "No se han encontrado coincidencias"
  }}); 
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>

<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="FACTURACION - ANALISIS Y FACTURACION - FACTURAS CON SALDOS APLICADOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0"  id="_tblMain">
	<tr>
		<td align="right">
		<div id="optDesc" class="TextInfo Text10">&nbsp;</div>
		<authtype type='59'><a href="javascript:goOption(11)" class="hint hint--left" data-hint="Otros Ajustes Factura (Descuentos)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,11)" onMouseOut="javascript:mouseOut(this,11)" src="../images/payment_adjust.gif"></a></authtype>
		<authtype type='52'><a href="javascript:goOption(2)" class="hint hint--left" data-hint="Estado de Cuenta detallado por factura"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/estado_de_cuenta_detallado_por_factura.png"></a></authtype>
		</td>
	</tr>

	<tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextFilter">
				<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fg",fg)%>

				<%
				String alFact ="";
				if(_comp.getHospital().trim().equals("S")){alFact = "P=PACIENTE,E=EMPRESAS,O=OTROS";}
				else alFact = "O=OTROS";
				
				alFact = "E=EMPRESAS";
				
				if(!fg.trim().equals("POS")){%>
				<td><cellbytelabel>Fecha Nac</cellbytelabel>.
				
					<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1"/>
						<jsp:param name="nameOfTBox1" value="fechaNac"/>
						<jsp:param name="valueOfTBox1" value=""/>
						<jsp:param name="fieldClass" value="Text10"/>
						<jsp:param name="buttonClass" value="Text10"/>
						<jsp:param name="clearOption" value="true"/>
					</jsp:include>
				
				<cellbytelabel>No. Paciente</cellbytelabel>
				<%=fb.intBox("codigo",codigo,false,false,false,10)%>
				<cellbytelabel>No. Admisi&oacute;n</cellbytelabel>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=fb.intBox("secuencia",secuencia,false,false,false,8)%>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cellbytelabel>Nombre</cellbytelabel>
				<%=fb.textBox("nombre",nombre,false,false,false,30)%>
				<cellbytelabel>No. Factura</cellbytelabel>
				<%=fb.textBox("factura",factura,false,false,false,10)%>
				</td>
			</tr>
			<tr class="TextFilter">
				<td><cellbytelabel>Empresa</cellbytelabel>
				<%//=fb.intBox("aseguradora",aseguradora,false,false,false,10,"Text10",null,null)%>
				<%//=fb.textBox("aseguradoraDesc",aseguradoraDesc,false,false,true,36,"Text10",null,null)%>
				<%//=fb.button("btnAseg","...",true,false,"Text10",null,"onClick=\"javascript:showEmpresaList()\"")%>
				
				
				<%=fb.select(ConMgr.getConnection(),"select a.codigo, a.nombre, (select descripcion from tbl_adm_tipo_empresa where codigo = a.tipo_empresa)||''||(select descripcion from tbl_adm_grupo_empresa where codigo = a.grupo_empresa) as grupo_descripcion from tbl_adm_empresa a  where a.estado = 'A'  order by 2","aseguradora",aseguradora,false,false,false,0,"Text10","width:290px",null,null,"")%>
				
				<cellbytelabel>Fecha</cellbytelabel>
				
					<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="2"/>
						<jsp:param name="nameOfTBox1" value="fDate"/>
						<jsp:param name="valueOfTBox1" value="<%=fDate%>"/>
						<jsp:param name="nameOfTBox2" value="tDate"/>
						<jsp:param name="valueOfTBox2" value="<%=tDate%>"/>
						<jsp:param name="fieldClass" value="Text10"/>
						<jsp:param name="buttonClass" value="Text10"/>
						<jsp:param name="clearOption" value="true"/>
					</jsp:include>
				<!--,A=ANULADA,C=CANCELADA -->
				<!--<cellbytelabel>Estado</cellbytelabel><%//=fb.select("estado","P=PENDIENTE",estado,false,false,0,"Text10",null,null,null,"")%>
				Factura De:<%//=fb.select("facturar_a",alFact,facturar_a,false,false,0,"Text10",null,null,null,"")%>-->
				<authtype type='60'>Facturas Sin Pago: <%=fb.checkbox("rechazadas","S",(rechazadas.equalsIgnoreCase("S")),false,null,null,"","CUENTAS RECHAZADAS POR LA ASEGURADORA")%></authtype>
				<%=fb.submit("go","Ir")%>
				<%}else{%>
			    
				Factura De:<%=fb.select("facturar_a",alFact,facturar_a,false,false,0,"Text10",null,null,null,"")%>
			   <%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, refer_to from tbl_fac_tipo_cliente where compania = "+session.getAttribute("_companyId")+" and activo_inactivo = 'A' order by 2","tipoRef",tipoRef,false,false,false,0,"Text10","",null,null,"S")%>
				<cellbytelabel>No. Cliente</cellbytelabel>&nbsp;&nbsp;&nbsp;<%=fb.textBox("refId",refId,false,false,false,5)%>&nbsp;&nbsp;&nbsp;<cellbytelabel>Nombre</cellbytelabel>&nbsp;&nbsp;&nbsp;<%=fb.textBox("nombre",nombre,false,false,false,30)%> <%=fb.submit("go","Ir")%></td>
				<%}%>
			</tr>
			<%=fb.formEnd(true)%>
			</table>
		</td>
	</tr>
	<tr>
		<td align="right"><%if(!fg.trim().equals("POS")){%><authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype><%}%>
		</td>
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
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fechaNac",fechaNac)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("secuencia",secuencia)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("factura",factura)%>
				<%=fb.hidden("aseguradora",aseguradora)%>
				<%=fb.hidden("aseguradoraDesc",aseguradoraDesc)%>
				<%=fb.hidden("fDate",fDate)%>
				<%=fb.hidden("tDate",tDate)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("facturar_a",facturar_a)%>
				<%=fb.hidden("tipoRef",tipoRef)%>
				<%=fb.hidden("refId",refId)%>
				<%=fb.hidden("rechazadas",rechazadas)%>
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
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fechaNac",fechaNac)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("secuencia",secuencia)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("factura",factura)%>
				<%=fb.hidden("aseguradora",aseguradora)%>
				<%=fb.hidden("aseguradoraDesc",aseguradoraDesc)%>
				<%=fb.hidden("fDate",fDate)%>
				<%=fb.hidden("tDate",tDate)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("facturar_a",facturar_a)%>
				<%=fb.hidden("tipoRef",tipoRef)%>
				<%=fb.hidden("refId",refId)%>
				<%=fb.hidden("rechazadas",rechazadas)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableRightBorder">
			<div id="_cMain" class="Container">
			<div id="_cContent" class="ContainerContent">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("index","")%>
			<%if(fg.trim().equals("POS")){%>
			 <tr class="TextHeader" align="center">
				<td width="10%"><cellbytelabel>Id. Cliente</cellbytelabel></td>
				<td width="50%"><cellbytelabel>Nombre</cellbytelabel></td>
				<td width="37%"><cellbytelabel>Tipo Cliente</cellbytelabel></td>
				<td width="3%">&nbsp;</td>
			 <tr>
			<%}else{%>
			<tr class="TextHeader" align="center">
				<td width="6%"><cellbytelabel>No. Factura</cellbytelabel></td>
				<td width="5%"><cellbytelabel>Fecha</cellbytelabel></td>
				<td width="7%"><cellbytelabel>Tipo Factura</cellbytelabel></td>
			<%if(facturar_a.trim().equals("")||!facturar_a.trim().equals("O")){%>
				<td width="6%"><cellbytelabel>Fecha Nac</cellbytelabel>.</td>
				<td width="4%"><cellbytelabel>No. Pacte</cellbytelabel></td>
				<td width="4%"><cellbytelabel>No. Adm</cellbytelabel>.</td><%}%>
				<td width="19%" align="left"><cellbytelabel>Nombre</cellbytelabel></td>
			<%if(facturar_a.trim().equals("")||!facturar_a.trim().equals("O")){%>
				<td width="19%" align="left"><cellbytelabel>Compa&ntilde;&iacute;a de Seguro</cellbytelabel></td>
			<%}%>
				<%if(facturar_a.trim().equals("")||!facturar_a.trim().equals("O")){%>
					<td width="5%"><cellbytelabel>Lista</cellbytelabel></td>
				<%}%>
				<td width="6%" align="right"><cellbytelabel>Monto</cellbytelabel></td>
				<%if(facturar_a.trim().equals("")||!facturar_a.trim().equals("O")){%>
					<td width="5%"><cellbytelabel>Pagado</cellbytelabel></td>
				<%}%>
				<td width="6%" align="right"><cellbytelabel>Saldo</cellbytelabel></td>
				<td width="3%">Dist</td>
				<td width="3%">&nbsp;</td>
			</tr>
			<%}%>
			<%
			for (int i=0; i<al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i);
				String color = "TextRow02";
				if (i % 2 == 0) color = "TextRow01";
			%>
			<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
			<%=fb.hidden("factura"+i,cdo.getColValue("cod_factura"))%>
			<%=fb.hidden("tipo_cob"+i,cdo.getColValue("tipo_cobertura"))%>
			<%=fb.hidden("pacId"+i,cdo.getColValue("pac_id"))%>
			<%=fb.hidden("noAdmision"+i,cdo.getColValue("admi_secuencia"))%>
			<%=fb.hidden("status"+i,cdo.getColValue("estatus"))%>
			<%=fb.hidden("facturar_a"+i,cdo.getColValue("facturar_a"))%>
			<%=fb.hidden("facImpresa"+i,cdo.getColValue("facImpresa"))%>
			<%=fb.hidden("ref_dgi"+i,cdo.getColValue("ref_dgi"))%>
			<%=fb.hidden("ref_type"+i,cdo.getColValue("ref_type"))%>
			<%=fb.hidden("ref_id"+i,cdo.getColValue("ref_id"))%>
			<%=fb.hidden("referTo"+i,cdo.getColValue("referTo"))%>
			<%=fb.hidden("si"+i,cdo.getColValue("saldoInicial"))%>
			<%=fb.hidden("puede_cancelar"+i,cdo.getColValue("puede_cancelar"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">

<%if(!fg.trim().equals("POS")){%>
			<td align="center"><!--<a href="javascript:showDetail('<%=cdo.getColValue("cod_factura")%>');" class="Link00">--><%=cdo.getColValue("cod_factura")%></td>
		<td align="center"><%=cdo.getColValue("fecha")%></td>
			<td align="center"><%=cdo.getColValue("tipo_factura")%></td>
		<%if(facturar_a.trim().equals("")||!facturar_a.trim().equals("O")){%>
			<td align="center"><%=cdo.getColValue("f_nac")%></td>
			<td align="center"><%=cdo.getColValue("pac_id")%></td>
			<td align="center"><%=cdo.getColValue("admi_secuencia")%></td><%}%>
			<td align="left"><%=cdo.getColValue("nombre")%></td>
			<%if(facturar_a.trim().equals("")||!facturar_a.trim().equals("O")){%><td align="left"><%=cdo.getColValue("nombre_empresa")%></td><%}%>
		<!--<td align="left"><%if(cdo.getColValue("estatus").trim().equals("A")){%> <font class="RedText"> <%=cdo.getColValue("estatusDesc")%> </font><%}else{%><%=cdo.getColValue("estatusDesc")%><%}%></td>-->
		<%if(facturar_a.trim().equals("")||!facturar_a.trim().equals("O")){%><td align="center"><%=cdo.getColValue("lista")%></td><%}%>
		<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("grang_total"))%></td>
		<%if(facturar_a.trim().equals("")||!facturar_a.trim().equals("O")){%>
		<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("pagado"))%></td>
		<%}%>
		<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("saldo"))%></td>
		<td align="center" class="hint hint--left" data-hint="Monto Dist.: <%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_dist"))%>">
		 <%
		 /*
		 double _saldo = cdo.getColValue("saldo")!=null&&!cdo.getColValue("saldo").equals("")?Double.parseDouble(cdo.getColValue("saldo")):0.0;
		 double grandTotal = cdo.getColValue("grang_total")!=null&&!cdo.getColValue("grang_total").equals("")?Double.parseDouble(cdo.getColValue("grang_total")):0.0;
		 boolean _continue =  _saldo > 0.0 && _saldo < grandTotal;*/
		 
		 boolean _continue = cdo.getColValue("monto_dist")!=null && !cdo.getColValue("monto_dist").equals("") && Double.parseDouble(cdo.getColValue("monto_dist")) > 0.0;
		 %>
		 <div id="dist<%=i%>" style="text-align:center; margin: auto 10px;"><%=_continue?"SI":"NO"%></div>
		</td>
		<td align="center">
		<%=fb.checkbox("check"+i,"",false,(!_continue && rechazadas.equalsIgnoreCase("")),null,null,"onClick=\"javascript:setIndex("+i+")\"")%>
		</td>
	<%}else{%>
				<td align="left"><%=cdo.getColValue("ref_id")%></td>
			<td><%=cdo.getColValue("nombre")%></td>
			<td><%=cdo.getColValue("referDesc")%></td>
			 <td align="center">&nbsp;<%=fb.checkbox("check"+i,"",false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%></td>
	<%}%>
	 </tr>

<%
}
%>
<%=fb.formEnd()%>
		</table>
</div>
</div>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fechaNac",fechaNac)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("factura",factura)%>
<%=fb.hidden("aseguradora",aseguradora)%>
<%=fb.hidden("aseguradoraDesc",aseguradoraDesc)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("facturar_a",facturar_a)%>
<%=fb.hidden("tipoRef",tipoRef)%>
<%=fb.hidden("refId",refId)%>
<%=fb.hidden("rechazadas",rechazadas)%>
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fechaNac",fechaNac)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("factura",factura)%>
<%=fb.hidden("aseguradora",aseguradora)%>
<%=fb.hidden("aseguradoraDesc",aseguradoraDesc)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("facturar_a",facturar_a)%>
<%=fb.hidden("tipoRef",tipoRef)%>
<%=fb.hidden("refId",refId)%>
<%=fb.hidden("rechazadas",rechazadas)%>
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
