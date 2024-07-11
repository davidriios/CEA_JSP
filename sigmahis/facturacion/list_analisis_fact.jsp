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
/**
==========================================================================================
==========================================================================================
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
StringBuffer sbSql= new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fg = request.getParameter("fg");
String fromNewView = request.getParameter("from_new_view");
int iconHeight = 40;
int iconWidth = 40;
double totMonto = 0.0, totSaldo = 0.0;
String sbFiltro="";
if (fg == null) fg = "AFA";
if (fromNewView == null) fromNewView = "";

if (fromNewView.trim().equals("Y")) {
	iconHeight = 35;
	iconWidth = 35;
}

if (request.getMethod().equalsIgnoreCase("GET"))
{
	boolean showDetPrint = false;
	boolean splitAdjustment = false;
	sbSql = new StringBuffer();
	sbSql.append("select nvl(get_sec_comp_param(-1,'FAC_PROFORMA_SHOW_DET'),'N') as show_proforma_det, nvl(get_sec_comp_param(-1,'FAC_SPLIT_ADJUSTMENT_ICON'),'N') as split_adjustment, nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'COD_EMP_PARTICULAR'),'-') as particular, nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'FAC_GEN_FACT_DBL_COB'),'A') as gen_type from dual");
	CommonDataObject p = SQLMgr.getData(sbSql.toString());
	if (p == null) {

		p = new CommonDataObject();
		p.addColValue("show_proforma_det","N");
		p.addColValue("split_adjustment","N");
		p.addColValue("particular","-");
		p.addColValue("gen_type","A");

	}
	showDetPrint = (p.getColValue("show_proforma_det").equalsIgnoreCase("Y") || p.getColValue("show_proforma_det").equalsIgnoreCase("S"));
	splitAdjustment = (p.getColValue("split_adjustment").equalsIgnoreCase("Y") || p.getColValue("split_adjustment").equalsIgnoreCase("S"));
	if (fg.equalsIgnoreCase("DCOB") && p.getColValue("particular").equals("-")) throw new Exception("Parámetro de Empresa Particular no definido!");

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
	String enviado = request.getParameter("enviado");
	String categoria = request.getParameter("categoria");
	String admType = request.getParameter("admType");


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
	if (enviado == null) enviado = "";
	if (categoria == null) categoria = "";
	if (admType == null) admType = "";


	if (!codigo.trim().equals("")) { sbFilter.append(" and a.pac_id like '%"); sbFilter.append(codigo); sbFilter.append("%'"); }
	if (!secuencia.trim().equals("")) { sbFilter.append(" and a.admi_secuencia like '%"); sbFilter.append(secuencia); sbFilter.append("%'"); }
	if (!nombre.trim().equals("")){
		sbFilter.append(" and upper(decode(a.facturar_a,'O',getNombreCliente(a.compania,a.cliente_otros,a.cod_otro_cliente),(select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id))) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'");
	}
	if (!categoria.trim().equals("")) { sbFilter.append(" and a.categoria_admi = "); sbFilter.append(categoria); sbFilter.append(""); }
	if (!admType.trim().equals("")) { sbFilter.append(" and a.adm_type = '"); sbFilter.append(admType); sbFilter.append("'"); }
	if (!factura.trim().equals("")) { sbFilter.append(" and upper(a.codigo) like '%"); sbFilter.append(factura.toUpperCase()); sbFilter.append("'"); }
	if (!fDate.trim().equals("")) { sbFilter.append(" and a.fecha >= to_date('"); sbFilter.append(fDate); sbFilter.append("','dd/mm/yyyy')"); }
	if (!tDate.trim().equals("")) { sbFilter.append(" and a.fecha <= to_date('"); sbFilter.append(tDate); sbFilter.append("','dd/mm/yyyy')"); }
	if (!facturar_a.trim().equals("")) {
		sbFilter.append(" and a.facturar_a = '"); sbFilter.append(facturar_a); sbFilter.append("'");
	}/* else {
		sbFilter.append(" and a.facturar_a in ('E','P')");
	}*/
	if (!fechaNac.trim().equals("")) { sbFilter.append(" and trunc(a.admi_fecha_nacimiento) = to_date('"); sbFilter.append(fechaNac); sbFilter.append("','dd/mm/yyyy')"); }
	if (!aseguradora.trim().equals("")) { sbFilter.append(" and a.cod_empresa = "); sbFilter.append(aseguradora); }
	if (!estado.trim().equals("")) { sbFilter.append(" and a.estatus = '"); sbFilter.append(estado); sbFilter.append("'"); }
	if (!refId.trim().equals("")) { sbFilter.append(" and (a.cod_otro_cliente = '"); sbFilter.append(refId.toUpperCase()); sbFilter.append("'"); }
	if (!tipoRef.trim().equals("")) { sbFilter.append(" and (a.cliente_otros = "); sbFilter.append(tipoRef); } //Esta condicion termina abajo Ojo
	/*if (!fg.equalsIgnoreCase("DCOB")){
	sbFilter.append(" or ( exists ( select null from tbl_adm_responsable r where r.estado ='A' and r.ref_id=");
	if (!refId.trim().equals("")) {sbFilter.append(" '");sbFilter.append(refId.toUpperCase()); sbFilter.append("'"); }
	else sbFilter.append(" a.cod_otro_cliente ");
	sbFilter.append(" and r.ref_type=");
	if (!tipoRef.trim().equals("")) {sbFilter.append(tipoRef);}
	else sbFilter.append(" a.cliente_otros ");
	sbFilter.append(" and r.pac_id=a.pac_id and r.admision=a.admi_secuencia and a.facturar_a='P' ))");
	}*/
	if (!tipoRef.trim().equals("")) sbFilter.append(")");//Ojo aqui termina la condicion de tipoRef
	if (!refId.trim().equals("")) {sbFilter.append(") ");}
	if (!enviado.trim().equals("")) { sbFilter.append(" and nvl(a.enviado,'N') = '"); sbFilter.append(enviado.toUpperCase()); sbFilter.append("'"); }

	if (request.getParameter("nombre") != null) {

		if (fg.equalsIgnoreCase("POS")) {

			sbSql = new StringBuffer();
			sbSql.append("select distinct (select getNombreCliente(a.compania,a.cliente_otros,a.cod_otro_cliente) from dual) as nombre, a.cliente_otros as ref_type, cod_otro_cliente as ref_id, (select refer_to from tbl_fac_tipo_cliente where codigo = a.cliente_otros and compania = a.compania) as referTo, (select descripcion from tbl_fac_tipo_cliente where codigo = a.cliente_otros and compania = a.compania) as referDesc from tbl_fac_factura a where a.estatus <> 'A' and  a.compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(sbFilter);
			sbSql.append(" order by 1");

		} else {

			if (fg.equalsIgnoreCase("DCOB")) {
				sbFilter.append(" and exists (select null from tbl_adm_beneficios_x_admision where pac_id = a.pac_id and admision = a.admi_secuencia and convenio_sol_emp = 'S' and estado = 'A') and (select count(*) from tbl_adm_beneficios_x_admision where pac_id = a.pac_id and admision = a.admi_secuencia and estado = 'A' and empresa not in (-1,");
				sbFilter.append(p.getColValue("particular"));
				sbFilter.append(")) > 1");
			}

			sbSql = new StringBuffer();
			sbSql.append("select a.codigo as cod_factura, a.numero_factura, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.tipo, a.estatus, a.grang_total, a.admi_codigo_paciente as codigo,decode(a.facturar_a,'O',(select getNombreCliente(a.compania,a.cliente_otros,a.cod_otro_cliente) from dual),(select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id)) as nombre,a.admi_secuencia, a.pac_id, a.cod_empresa, decode(a.facturar_a,'P','Paciente','E','Empresa','O','Otros') as tipo_factura, to_char(a.admi_fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, a.admi_codigo_paciente, (select d.nombre from tbl_adm_empresa d where d.codigo = a.cod_empresa) as nombre_empresa, decode(a.estatus,'A','ANULADA','P','PENDIENTE','C','CANCELADA') as estatusDesc");
			sbSql.append(", nvl(join(cursor(select distinct (select lista from tbl_fac_lista_envio where compania = led.compania and id = led.id) from tbl_fac_lista_envio_det led where led.estado = 'A' and led.factura = a.codigo and led.compania = a.compania and exists (select null from tbl_fac_lista_envio where compania = led.compania and id = led.id and estado = 'A')),', '),' ') as lista");
			sbSql.append(", a.tipo_cobertura, a.compania, a.facturar_a, nvl((select count(*) from tbl_fac_dgi_documents where tipo_docto in ('FACP','FACT') and impreso = 'Y' and compania = a.compania and codigo = a.codigo),0) as facImpresa, nvl((select id from tbl_fac_dgi_documents where tipo_docto in('FACP','FACT') and codigo = a.codigo and rownum = 1 and compania = a.compania),0) as ref_dgi, a.cliente_otros as ref_type, cod_otro_cliente as ref_id, (select refer_to from tbl_fac_tipo_cliente where codigo = a.cliente_otros and compania = a.compania) as referTo, decode(comentario,'S/I','S','N') saldoInicial, (select fn_cja_saldo_fact(a.facturar_a, a.compania,a.codigo,a.grang_total) from dual) as saldo,a.f_anio as anio, a.comentario_an, usuario_anulacion, to_char(fecha_anulacion,'dd/mm/yyyy') as fecha_anulacion, nvl((select anio || ' - ' || lista from tbl_cxc_cuentasm m where status = 'O' and m.compania = a.compania and m.factura = a.codigo and rownum = 1), '') incobrable, (select tipo_cta from tbl_adm_admision where pac_id = a.pac_id and secuencia = a.admi_secuencia) as tipo_cta from tbl_fac_factura a where a.compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			//sbSql.append(" and a.facturar_a in('E','P') ");
			sbSql.append("/***************************************/");
			sbSql.append(sbFilter);
			sbSql.append("/***************************************/");
			//sbSql.append(" order by a.fecha desc, a.codigo desc");
			sbSql.append(" order by a.f_anio desc,a.numero_factura desc");
		}
		sbFiltro = sbFilter.toString();
		if (!sbFiltro.trim().equals("")) {
			al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
			rowCount = CmnMgr.getCount("select count(*) count from ("+sbSql+")");
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
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Facturacion - '+document.title;
var gTitleAlert = '<%=java.util.ResourceBundle.getBundle("issi").getString("windowTitle")%>';
function printList(tipo){if(!tipo)abrir_ventana('../facturacion/print_list_analisis_fact.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>&fg=<%=fg%>');
else{ <%if(!sbFiltro.trim().equals("")){%>abrir_ventana('../cellbyteWV/report_container.jsp?reportName=facturacion/rpt_list_analisis_fact.rptdesign&appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>&fg=<%=fg%>&pCtrlHeader=true');<%}else{%>CBMSG.warning('Favor agregar filtros de busqueda.!');<%}%>}}
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
	case 17:msg='Ver Factura Fiscal';break;
	case 18:msg='Ajustes a Facturas Doble Cobertura';break;
	case 19:msg='Imprimir Detalles de Cargos';break;
	case 20:msg='Imprimir Detalles de Cargos Netos';break;
	case 21:msg='Anular Factura(Impresa Fiscal)';break;
	case 22:msg='Ajustes Correccion Fiscal POS';break;
	case 23:msg='Otros Ajustes Factura Cta. Particular (Descuentos)';break;
	case 24:msg='Generar Factura Doble Cobertura Manual';break;
	case 25:msg='Ajuste Automatico';break;
		case 26:msg='Registrar Pago';break;

	}
	setoverc(obj,'ImageBorderOver');
	optDescObj.innerHTML=msg;
	obj.alt=msg;
}
function goOption(option)
{
	if(option==0)abrir_ventana('../facturacion/reg_analisis_fact.jsp?mode=add&fg=<%=fg%>&noAdmision=<%=secuencia%>&pacienteId=<%=codigo%>&from_new_view=<%=fromNewView%>');
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
			var incobrable = eval('document.form0.incobrable'+k).value;
			var si = eval('document.form0.si'+k).value;
			if(noAdmision=='0'&&(option==1||option==13||option==14||option==15||option==22||option==17||option==19||option==20||option==21))CBMSG.warning('La opción no aplica para Facturas de Saldo Inicial!');
			else if(facturar_a !='O'||option==16||option==11||option==17||option==22||option==2||option==12){
			if((option!=2 &&option!=4&&option!=5&&option!=13&&option!=14&&option!=16&&option!=17&&option!=19&&option!=20) && status=='A')CBMSG.warning('El Estado de la Factura no permite esta Accion!!!');
			else if(option==1)if(facturar_a !='O'){if(facImpresa!='0'){CBMSG.warning('La factura a anular ya fue impresa Fiscalmente.\n Favor Solicitarle a su supervisor la anulacion.');} else if(incobrable!=''){CBMSG.warning('La factura se encuentra en la lista '+incobrable+ ' de ajustes en lote!');} else { showPopWin('../common/run_process.jsp?fp=factura&actType=7&docType=FACT&docId='+factura+'&docNo='+factura+'&compania='+compania+'&tipoCob='+tipo_cob+'&pacId='+pacId+'&noAdmision='+noAdmision,winWidth*.75,winHeight*.65,null,null,'');}}else CBMSG.warning('Solo para Facturas de Pacientes Y Empresas');
			else if(option==21)if(facturar_a !='O'){if(facImpresa!='0'){CBMSG.warning('La factura a anular ya fue impresa Fiscalmente.\n Favor revisar e Imprimir su Respecitva nota de Credito.');}  else if(incobrable!=''){CBMSG.warning('La factura se encuentra en la lista '+incobrable+ ' de ajustes en lote!');} showPopWin('../common/run_process.jsp?fp=factura&actType=7&docType=FACT&docId='+factura+'&docNo='+factura+'&compania='+compania+'&tipoCob='+tipo_cob+'&pacId='+pacId+'&noAdmision='+noAdmision,winWidth*.75,winHeight*.65,null,null,'');}else CBMSG.warning('Solo para Facturas de Pacientes Y Empresas');
			else if(option==2)abrir_ventana1('../facturacion/print_estado_cargo_det.jsp?factId='+factura+'&pacId='+pacId+'&refId='+ref_id+'&referTo='+referTo+'&refType='+ref_type+'&facturarA='+facturar_a);
			else if(option==3)abrir_ventana1('../facturacion/reg_ajuste_factura.jsp?fg=CARGO&factura='+factura+'&pacId='+pacId+'&noAdmision='+noAdmision+'&ref_type='+ref_type+'&ref_id='+ref_id);
			else if(option==4){<% if (showDetPrint) { %>if(confirm('La impresión es resumida, seleccione aceptar si desea verla detallada!'))abrir_ventana1('../facturacion/print_dfact.jsp?preprinted&factura='+factura+'&compania='+compania);else <% } %>abrir_ventana1('../facturacion/print_fact.jsp?factura='+factura+'&compania='+compania);}
			else if(option==5){<% if (showDetPrint) { %>if(confirm('La impresión es resumida, seleccione aceptar si desea verla detallada!'))abrir_ventana1('../facturacion/print_dfact.jsp?factura='+factura+'&compania='+compania);else <% } %>abrir_ventana1('../facturacion/print_factura.jsp?factura='+factura+'&compania='+compania);}
			else if(option==6)abrir_ventana1('../facturacion/reg_ajuste_factura.jsp?fg=DEV&factura='+factura+'&pacId='+pacId+'&noAdmision='+noAdmision+'&ref_type='+ref_type+'&ref_id='+ref_id);
			else if(option==7)if(parseInt(noAdmision)>0)abrir_ventana1('../facturacion/notas_ajuste_cargo_dev.jsp?pacienteId='+pacId+'&noAdmision='+noAdmision+'&factura='+factura+'&nt=C&fg=C&tr=RE&ref_type='+ref_type+'&ref_id='+ref_id);else CBMSG.warning('OPCION INVALIDA PARA FACTURAS DE SALDO INICIAL');
			else if(option==8)if(parseInt(noAdmision)>0)abrir_ventana1('../facturacion/notas_ajuste_cargo_dev.jsp?pacienteId='+pacId+'&noAdmision='+noAdmision+'&factura='+factura+'&nt=D&fg=D&tr=RE&ref_type='+ref_type+'&ref_id='+ref_id);else CBMSG.warning('OPCION INVALIDA PARA FACTURAS DE SALDO INICIAL');
			else if(option==9)if(parseInt(noAdmision)>0)abrir_ventana1('../facturacion/notas_ajuste_cargo_dev.jsp?pacienteId='+pacId+'&noAdmision='+noAdmision+'&factura='+factura+'&nt=H&fg=C&tr=RE&ref_type='+ref_type+'&ref_id='+ref_id);else CBMSG.warning('OPCION INVALIDA PARA FACTURAS DE SALDO INICIAL');
			else if(option==10){
			if(parseInt(noAdmision)>0){
				/*var pagos = getDBData('<%=request.getContextPath()%>','chkPagoFact(<%=(String) session.getAttribute("_companyId")%>, \''+factura+'\')','dual','');
				if(pagos=='S') CBMSG.warning('Esta factura tiene pagos aplicados, Favor Verifique los Saldo de los centros que tienen Distribuciones!!');
				else*/abrir_ventana1('../facturacion/notas_ajuste_cargo_dev.jsp?pacienteId='+pacId+'&noAdmision='+noAdmision+'&factura='+factura+'&nt=H&fg=D&tr=RE&ref_type='+ref_type+'&ref_id='+ref_id);
			} else CBMSG.warning('OPCION INVALIDA PARA FACTURAS DE SALDO INICIAL');
			} else if(option==11){
				if(facturar_a=='O' && si!='S') abrir_ventana1('../pos/notas_ajustes_otros.jsp?codigo='+factura+'&ref_type='+ref_type+'&ref_id='+ref_id);
				else {/*var pagos = getDBData('<%=request.getContextPath()%>','chkPagoFact(<%=(String) session.getAttribute("_companyId")%>, \''+factura+'\')','dual','');
				if(pagos=='S') CBMSG.warning('Esta factura tiene pagos aplicados, Favor Verifique los Saldo de los centros que tienen Distribuciones!!');
				else*/
				<% if (splitAdjustment) { %>if(eval('document.form0.tipo_cta'+k).value=='A')<% } %>abrir_ventana1('../facturacion/notas_ajustes_config.jsp?fg=AF&fp=notas&factura='+factura+'&ref_type='+ref_type+'&ref_id='+ref_id);
				<% if (splitAdjustment) { %>else CBMSG.warning('SOLO PARA TIPO DE CUENTA ASEGURADORA!!');<% } %>
				}
			}else if(option==12){var estado ='';var ubicacion ='';if(status == "P"){estado ='C';ubic = 'COBROS';}else if(status == "C"){estado ='P';ubicacion = 'ANALISIS';} if(status=='P' && eval('document.form0.puede_cancelar'+k).value=='N')CBMSG.warning('No puede Cancelar una Factura con Saldo!'); else showPopWin('../common/run_process.jsp?fp=UPDFACT&actType=50&docType=UPDFACT&estado='+estado+'&ubicacion='+ubicacion+'&docNo='+factura+'&compania='+compania,winWidth*.75,winHeight*.65,null,null,'');}
			else if(option==13){abrir_ventana('../admision/consulta_general.jsp?mode=view&pacId='+pacId+'&noAdmision='+noAdmision);}
			else if(option==14) abrir_ventana1('../facturacion/print_cargo_dev_resumen2.jsp?noSecuencia='+noAdmision+'&pacId='+pacId+'&tf=');
			else if(option==15) abrir_ventana1('../facturacion/reg_facturacion_manual.jsp?noAdmision='+noAdmision+'&pacId='+pacId+'&mode=view');
			else if(option==16)printRFP(ref_id,ref_type,referTo);
			else if(option==17)showDgi(refDgi);
			else if(option==18)if(facturar_a =='E'){abrir_ventana1('../cxc/ajuste_automatico_config.jsp?noAdmision='+noAdmision+'&pacienteId='+pacId+'&factura='+factura);}else CBMSG.warning('La factura seleccionada no Aplica para este Proceso!!!!');
			else if(option==19){if(facturar_a !='O'){abrir_ventana('../facturacion/print_cargo_dev.jsp?noSecuencia='+noAdmision+'&pacId='+pacId);}}
			else if(option==20){if(facturar_a !='O'){abrir_ventana('../facturacion/print_cargo_dev_neto.jsp?noSecuencia='+noAdmision+'&pacId='+pacId);}}
			else if(option==22){if(facturar_a =='O'){abrir_ventana1('../facturacion/notas_ajustes_config.jsp?fp=POS&fg=AF&factura='+factura+'&ref_type='+ref_type+'&ref_id='+ref_id);}else CBMSG.warning('Solo para facturas de Otros clientes.');}
			else if(option==23){
				if(eval('document.form0.tipo_cta'+k).value=='P')abrir_ventana1('../facturacion/notas_ajustes_config.jsp?fg=AF&fp=notas&factura='+factura+'&ref_type='+ref_type+'&ref_id='+ref_id);
				else CBMSG.warning('SOLO PARA TIPO DE CUENTA PARTICULAR!!');
			} else if(option==24) {
				showPopWin('../process/fac_doble_cobertura.jsp?compania='+compania+'&pacId='+pacId+'&admision='+noAdmision,winWidth*.75,winHeight*.65,null,null,'');
			}
			else if(option==25){var saldo = eval('document.form0.saldo'+k).value;if(facturar_a !='O'){if(parseFloat(saldo)>0){abrir_ventana1('../facturacion/notas_ajustes_config.jsp?fg=AF&fp=notas&isAjusteAut=Y&factura='+factura+'&ref_type='+ref_type+'&ref_id='+ref_id);}else {CBMSG.warning('La factura no tiene saldo para realizar Nota de Credito.');}}else CBMSG.warning('Opciones Solo para Facturas de Pacientes y Empresas');}
			else if(option==26){var saldo = eval('document.form0.saldo'+k).value;if(facturar_a !='O'){if(parseFloat(saldo)>0){abrir_ventana1('../caja/reg_recibo.jsp?tipoCliente='+facturar_a+'&mode=add&fp=factura&pac_id='+pacId+'&factura='+factura+'&refId='+ref_id);}else {CBMSG.warning('La factura no tiene saldo para registrar pago.');}}else CBMSG.warning('Opciones Solo para Facturas de Pacientes y Empresas');}
			}else CBMSG.warning('Opciones Solo para Facturas de Pacientes y Empresas');
		}
	}
	}
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();if('<%=fg%>'=='POS'){showOtros(document.search01.facturar_a.value);}}
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
function showOtros(tp){
	if(tp==undefined||tp==null)tp='P';
	if(tp!='O'){
		document.search01.tipoRef.style.display='none';
	}
	else { document.search01.tipoRef.style.display='';document.search01.tipoRef.value=';'}
}
$(function(){
	$(".motivoAnul").tooltip({
	content: function () {

		var $i = $(this).data("i");
		var $type = $(this).data("type");
		var $title = $($(this).prop('title'));
		var $content;

		if($type == "2" ) $content = $("#motivoAnulCont"+$i).val();

		var $cleanContent = $($content).text();
		if (!$cleanContent) $content = "";
		return $content;
	}
	,track: true
	,position: { my: "left+15 center", at: "right center", collision: "flipfit" }
	});
});
</script>
<%if(fromNewView.equalsIgnoreCase("Y")){%>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script>
<%}%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%if(fg.equals("AFA")){%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="FACTURACION - ANALISIS Y FACTURACION DE LA ADMISION"></jsp:param>
</jsp:include>
<%}else if(fg.equals("POS")){%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="FACTURACION - ESTADO DE CUENTA"></jsp:param>
</jsp:include>
<%}else if(fg.equals("DCOB")){%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="FACTURACION - CUENTAS DOBLE COBERTURA"></jsp:param>
</jsp:include>
<%}%>

<%
String hintPos = "hint--top";
if (fromNewView.equalsIgnoreCase("Y")) hintPos = "hint--left";
%>
<table align="center" width="99%" cellpadding="1" cellspacing="0"  id="_tblMain">
	<tr>
		<td align="right">
		<div id="optDesc" class="TextInfo Text10">&nbsp;</div>
		<%if(!fg.trim().equals("POS")){%><authtype type='3'><a href="javascript:goOption(0)" class="hint <%=hintPos%>" data-hint="Registrar Analisis"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,0)" onMouseOut="javascript:mouseOut(this,0)" src="../images/registrar_analisis.png"></a></authtype>
		<authtype type='7'><a href="javascript:goOption(1)" class="hint <%=hintPos%>" data-hint="Anular Factura"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder  image-contrast" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/anular_factura.png"></a></authtype>
		<authtype type='69'><a href="javascript:goOption(21)" class="hint <%=hintPos%>" data-hint="Anular Factura (Impresa Fiscal)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder  image-contrast" onMouseOver="javascript:mouseOver(this,21)" onMouseOut="javascript:mouseOut(this,21)" src="../images/anular_factura_impresa_fiscal.png"></a></authtype>
		<authtype type='52'><a  href="javascript:goOption(2)" class="hint <%=hintPos%>" data-hint="Estado de Cuenta Detallado por Factura"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,2);" onMouseOut="javascript:mouseOut(this,2)" src="../images/estado_de_cuenta_detallado_por_factura.png"></a></authtype>
		<!--<authtype type='53'><a href="javascript:goOption(3)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/shopping-cart-full-plus.gif"></a></authtype>
		<authtype type='54'><a href="javascript:goOption(6)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,6)" onMouseOut="javascript:mouseOut(this,6)" src="../images/drug-basket.jpg"></a></authtype>--><!--Se comenta pendiente terminar los ajustes detallados-->
		<authtype type='2'><a href="javascript:goOption(4)" class="hint <%=hintPos%>" data-hint="Imprimir Factura Pre - Impresa"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,4)" onMouseOut="javascript:mouseOut(this,4)" src="../images/imprimir_factura_pre_impresa.png"></a></authtype>
		<authtype type='2'><a href="javascript:goOption(5)" class="hint <%=hintPos%>" data-hint="Imprimir Factura"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,5)" onMouseOut="javascript:mouseOut(this,5)" src="../images/imprimir_factura.png"></a></authtype>
		<authtype type='55'><a href="javascript:goOption(7)" class="hint <%=hintPos%>" data-hint="Ajustes por Cargo tardio"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,7)" onMouseOut="javascript:mouseOut(this,7)" src="../images/ajuste_por_cargo_tardio.png"></a></authtype>
		<authtype type='56'><a href="javascript:goOption(8)" class="hint <%=hintPos%>" data-hint="Ajuste Devolución"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,8)" onMouseOut="javascript:mouseOut(this,8)" src="../images/ajuste_devolucion.png"></a></authtype>
		<authtype type='57'><a href="javascript:goOption(9)" class="hint <%=hintPos%>" data-hint="Ajustes por Cargo tardio (Honorarios)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,9)" onMouseOut="javascript:mouseOut(this,9)" src="../images/ajuste_por_cargo_tardio_honorario.png"></a></authtype>
		<authtype type='58'><a href="javascript:goOption(10)" class="hint <%=hintPos%>" data-hint="Ajuste Devolución (Honorarios)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,10)" onMouseOut="javascript:mouseOut(this,10)" src="../images/ajuste_devolucion_honorarios.png"></a></authtype>
		<authtype type='59'><a href="javascript:goOption(11)" class="hint <%=hintPos%>" data-hint="Otros Ajustes Factura (Descuentos)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,11)" onMouseOut="javascript:mouseOut(this,11)" src="../images/otros_ajustes_factura_descuento.png"></a></authtype>
		<% if (splitAdjustment) { %><authtype type='71'><a href="javascript:goOption(23)" class="hint <%=hintPos%>" data-hint="Otros Ajustes Factura Cta. Particular (Descuentos)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,23)" onMouseOut="javascript:mouseOut(this,23)" src="../images/payment_adjust.gif"></a></authtype><% } %>
		<authtype type='60'><a href="javascript:goOption(12)" class="hint <%=hintPos%>" data-hint="Cambio de Estado de Factura"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,12)" onMouseOut="javascript:mouseOut(this,12)" src="../images/cambio_de_estado_de_factura.png"></a></authtype>
		<authtype type='61'><a href="javascript:goOption(13);" class="hint <%=hintPos%>" data-hint="Consulta General de Admisiones"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,13)" onMouseOut="javascript:mouseOut(this,13)" src="../images/consulta_general_de_admisiones.png"></a></authtype>
		<authtype type='62'><a href="javascript:goOption(14);" class="hint <%=hintPos%>" data-hint="Imprimir Análisis"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,14)" onMouseOut="javascript:mouseOut(this,14)" src="../images/imprimir_analisis.png"></a></authtype>
		<authtype type='63'><a href="javascript:goOption(15);" class="hint <%=hintPos%>" data-hint="Ver Análisis"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,15)" onMouseOut="javascript:mouseOut(this,15)" src="../images/ver_analisis.png"></a></authtype>
		<authtype type='64'><a href="javascript:goOption(16);" class="hint <%=hintPos%>" data-hint="Estado de Cuenta"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,16)" onMouseOut="javascript:mouseOut(this,16)" src="../images/estado_de_cuenta.png"></a></authtype>
		<authtype type='65'><a href="javascript:goOption(17);" class="hint <%=hintPos%>" data-hint="Ver Factura Fiscal"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,17)" onMouseOut="javascript:mouseOut(this,17)" src="../images/ver_factura.png"></a></authtype>
		<%}else{%>
		<authtype type='64'><a href="javascript:goOption(16);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,16)" onMouseOut="javascript:mouseOut(this,16)" src="../images/print_bills.gif"></a></authtype>
		<%}%>
		<%if(fg.trim().equals("DCOB")){%>
				<authtype type='66'><a href="javascript:goOption(18);" class="hint <%=hintPos%>" data-hint="Ajustes a Factura Doble Cobertura"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,18)" onMouseOut="javascript:mouseOut(this,18)" src="../images/flash_auto.png"></a></authtype>
				<% if (p.getColValue("gen_type").equalsIgnoreCase("M")) { %><authtype type='72'><a href="javascript:goOption(24);" class="hint <%=hintPos%>" data-hint="Generar Factura Doble Cobertura Manual"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,24)" onMouseOut="javascript:mouseOut(this,24)" src="../images/dollar_circle.gif"></a></authtype><% } %>
		<%}%>
		<% if(!fg.equalsIgnoreCase("POS")) { %><authtype type='67'><a href="javascript:goOption(19)" class="hint hint--left" data-hint="Imprimir Detalles de Cargos"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,19)" onMouseOut="javascript:mouseOut(this,19)" src="../images/imprimir_detalles_de_cargo.png"></a></authtype>
		<authtype type='68'><a href="javascript:goOption(20)" class="hint hint--left" data-hint="Imprimir Detalles de Cargos Netos"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,20)" onMouseOut="javascript:mouseOut(this,20)" src="../images/imprimir_detalles_de_cargos_neto.png"></a></authtype>
		<authtype type='70'><a href="javascript:goOption(22)" class="hint hint--left" data-hint="Ajustes Corrección Fiscal POS"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,22)" onMouseOut="javascript:mouseOut(this,22)" src="../images/ajustes_correccion_fiscal_pos.png"></a></authtype>
		<authtype type='73'><a href="javascript:goOption(25)" class="hint hint--left" data-hint="Ajuste automatico (Descuentos)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,25)" onMouseOut="javascript:mouseOut(this,25)" src="../images/payment_adjust.gif"></a></authtype>
		<authtype type='74'><a href="javascript:goOption(26)" class="hint hint--left" data-hint="Registrar Pago"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,26)" onMouseOut="javascript:mouseOut(this,26)" src="../images/dollar_circle.gif"></a></authtype>
		<% } %>
		</td>
	</tr>

	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================
-->
			<table width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fg",fg)%>
<%
String alFact ="";
if(_comp.getHospital().trim().equals("S")){alFact = "P=PACIENTE,E=EMPRESAS,O=OTROS";}
else alFact = "O=OTROS";

if (!fg.trim().equals("POS")) {
%>
			<tr class="TextFilter"<%=!fromNewView.trim().equals("")?" style='display:none'": ""%>>
				<td width="30%">
					<cellbytelabel>Fecha Nac.</cellbytelabel>
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1"/>
					<jsp:param name="nameOfTBox1" value="fechaNac"/>
					<jsp:param name="valueOfTBox1" value=""/>
					<jsp:param name="fieldClass" value="Text10"/>
					<jsp:param name="buttonClass" value="Text10"/>
					<jsp:param name="clearOption" value="true"/>
					</jsp:include>
				</td>
				<td width="20%">
					<cellbytelabel>No. Paciente</cellbytelabel>
					<%=fb.intBox("codigo",codigo,false,false,false,10)%>
				</td>
				<td width="20%">
					<cellbytelabel>No. Admisi&oacute;n</cellbytelabel>
					<%=fb.intBox("secuencia",secuencia,false,false,false,8)%>
				</td>
				<td width="30%">
					<cellbytelabel>Nombre</cellbytelabel>
					<%=fb.textBox("nombre",nombre,false,false,false,30)%>
				</td>
			</tr>
			<tr class="TextFilter"<%=!fromNewView.trim().equals("")?" style='display:none'": ""%>>
				<td>
					<cellbytelabel>No. Factura</cellbytelabel>
					<%=fb.textBox("factura",factura,false,false,false,10)%>
				</td>
				<td>
					<cellbytelabel>Estado</cellbytelabel>
					<%=fb.select("estado","P=PENDIENTE,A=ANULADA,C=CANCELADA",estado,false,false,0,"Text10",null,null,null,"S")%>
				</td>
				<td>
					Factura De
					<%=fb.select("facturar_a",alFact,facturar_a,false,false,0,"Text10",null,null,null,(fg.trim().equals("DCOB"))?"S":"T")%>
				</td>
				<td>
					<cellbytelabel>Enviada</cellbytelabel>
					<%=fb.select("enviado","S=SI,N=NO",enviado,false,false,0,"Text10",null,null,null,"S")%>
				</td>
			</tr>
			<tr class="TextFilter"<%=!fromNewView.trim().equals("")?" style='display:none'": ""%>>
				<td colspan="3">
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
					Categoria: <%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo categoria from tbl_adm_categoria_admision order by 1","categoria",categoria,"S")%>Tipo Adm <%=fb.select(ConMgr.getConnection(),"select distinct adm_type,decode(adm_type,'I','ADMISIONES - IP','ADMISIONES - OP') as tipo from tbl_adm_categoria_admision order by 1","admType",admType,"S")%>
				</td>
				<td colspan="2">
					<cellbytelabel>Empresa</cellbytelabel>
					<%=fb.intBox("aseguradora",aseguradora,false,false,false,10,"Text10",null,null)%>
					<%=fb.textBox("aseguradoraDesc",aseguradoraDesc,false,false,true,36,"Text10",null,null)%>
					<%=fb.button("btnAseg","...",true,false,"Text10",null,"onClick=\"javascript:showEmpresaList()\"")%>
					<%=fb.submit("go","Ir")%>
				</td>
			</tr>
<% } else { %>
			<tr class="TextFilter">
				<td>
					Factura De
					<%=fb.select("facturar_a",alFact,facturar_a,false,false,0,null,null,"onChange=\"javascript:showOtros(this.value)\"")%>

					<%//=fb.select("facturar_a",alFact,facturar_a,false,false,0,"Text10",null,null,null,"")%>

				<span id="blkTipoRef"><%=fb.select(ConMgr.getConnection(),"select codigo, codigo||' - '||descripcion, refer_to from tbl_fac_tipo_cliente where compania = "+session.getAttribute("_companyId")+" and activo_inactivo = 'A' order by descripcion","tipoRef",tipoRef,false,false,false,0,null,null,"onChange=\"javascript:showOtros(document.search01.facturar_a.value)\"",null,"S")%></span>


					<cellbytelabel>No. Cliente</cellbytelabel>
					<%=fb.textBox("refId",refId,false,false,false,5)%>
					<cellbytelabel>Nombre</cellbytelabel>
					<%=fb.textBox("nombre",nombre,false,false,false,30)%>
					<%=fb.submit("go","Ir")%>
				</td>
			</tr>
<% } %>
	<%=fb.formEnd(true)%>
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
	<tr>
		<td align="right"><%if(!fg.trim().equals("POS")){%><authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a>&nbsp;|&nbsp;<a href="javascript:printList(1)" class="Link00">[ <cellbytelabel>Imprimir Lista (Excel)</cellbytelabel> ]</a></authtype><%}%>
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
<%=fb.hidden("enviado",enviado)%>
<%=fb.hidden("categoria",""+categoria)%>
<%=fb.hidden("from_new_view", fromNewView)%>
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
<%=fb.hidden("enviado",enviado)%>
<%=fb.hidden("categoria",""+categoria)%>
<%=fb.hidden("from_new_view", fromNewView)%>
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

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

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
			<td width="5%"><cellbytelabel>Año</cellbytelabel></td>
			<td width="6%"><cellbytelabel>No. Factura</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Fecha</cellbytelabel></td>
			<td width="6%"><cellbytelabel>Tipo Factura</cellbytelabel></td>
		<%if(facturar_a.trim().equals("")||!facturar_a.trim().equals("O")){%>
			<!--<td width="6%"><cellbytelabel>Fecha Nac</cellbytelabel>.</td>-->
			<td width="4%"><cellbytelabel>No. Pacte</cellbytelabel></td>
			<td width="4%"><cellbytelabel>No. Adm</cellbytelabel>.</td><%}%>
			<td width="21%"><cellbytelabel>Nombre</cellbytelabel></td>
		<%if(facturar_a.trim().equals("")||!facturar_a.trim().equals("O")){%><td width="21%"><cellbytelabel>Compa&ntilde;&iacute;a de Seguro</cellbytelabel></td><%}%>
			<td width="5%"><cellbytelabel>Estado</cellbytelabel></td>
		 <%if(facturar_a.trim().equals("")||!facturar_a.trim().equals("O")){%>
			<td width="5%"><cellbytelabel>Lista</cellbytelabel></td><%}%>
			<td width="5%"><cellbytelabel>Monto</cellbytelabel></td>
			<td width="6%"><cellbytelabel>Saldo</cellbytelabel>.</td>
			<td width="2%">&nbsp;</td>
		</tr>
	<%}%>
<%

for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	String puede_cancelar="N";
	if (i % 2 == 0) color = "TextRow01";
	if (!fg.trim().equals("POS")){if(Double.parseDouble(cdo.getColValue("saldo")) > 0)puede_cancelar="N"; else puede_cancelar="S";}

		if (cdo.getColValue("estatusDesc") != null && !cdo.getColValue("estatusDesc").equals("") && !cdo.getColValue("estatusDesc").equalsIgnoreCase("ANULADA")) {
			totMonto += Double.parseDouble(cdo.getColValue("grang_total","0"));
			totSaldo += Double.parseDouble(cdo.getColValue("saldo","0"));
		}
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
<%=fb.hidden("puede_cancelar"+i,puede_cancelar)%>
<%=fb.hidden("saldo"+i,cdo.getColValue("saldo"))%>
<%=fb.hidden("incobrable"+i,cdo.getColValue("incobrable"))%>
<%=fb.hidden("tipo_cta"+i,cdo.getColValue("tipo_cta"))%>
<%=fb.hidden("motivoAnulCont"+i,"<label class='motivoAnulCont' style='font-size:11px'><strong>"+(cdo.getColValue("usuario_anulacion")==null?"":cdo.getColValue("usuario_anulacion"))+"</strong><strong>"+(cdo.getColValue("fecha_anulacion")==null?"":", "+cdo.getColValue("fecha_anulacion"))+"</strong><br/>"+(cdo.getColValue("comentario_an")==null?"":cdo.getColValue("comentario_an"))+"</label>")%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">

<%if(!fg.trim().equals("POS")){%>
			<td align="center"><%=cdo.getColValue("anio")%></td>
			<td align="center"><!--<a href="javascript:showDetail('<%=cdo.getColValue("cod_factura")%>');" class="Link00">--><%=cdo.getColValue("cod_factura")%></td>
			<td align="center"><%=cdo.getColValue("fecha")%></td>
			<td align="center"><%=cdo.getColValue("tipo_factura")%></td>
		<%if(facturar_a.trim().equals("")||!facturar_a.trim().equals("O")){%>
			<!--<td align="center"><%=cdo.getColValue("fecha_nacimiento")%></td>-->
			<td align="center"><%=cdo.getColValue("pac_id")%></td>
			<td align="center"><%=cdo.getColValue("admi_secuencia")%></td><%}%>
			<td align="left"><%=cdo.getColValue("nombre")%></td>
			<%if(facturar_a.trim().equals("")||!facturar_a.trim().equals("O")){%><td align="left"><%=cdo.getColValue("nombre_empresa")%></td><%}%>
		<td align="left">
		<%if(cdo.getColValue("estatus").trim().equals("A")){%>
		<span class="motivoAnul" title="" data-i="<%=i%>" data-type="2"><%=cdo.getColValue("estatusDesc")%></span>
		<!--<font class="RedText"> <%=cdo.getColValue("estatusDesc")%>--> </font>
		<%}else{%>
		<%=cdo.getColValue("estatusDesc")%><%}%>
		</td>
		<%if(facturar_a.trim().equals("")||!facturar_a.trim().equals("O")){%><td align="center"><%=cdo.getColValue("lista")%></td><%}%>
		<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("grang_total"))%></td>
		<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("saldo"))%></td>
		<td align="center">&nbsp;<%=fb.checkbox("check"+i,"",false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%></td>
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
<%=fb.hidden("enviado",enviado)%>
<%=fb.hidden("categoria",""+categoria)%>
<%=fb.hidden("from_new_view", fromNewView)%>
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
<%=fb.hidden("enviado",enviado)%>
<%=fb.hidden("categoria",""+categoria)%>
<%=fb.hidden("from_new_view", fromNewView)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
<%if(!fg.equals("POS")){%>
		<tr class="TextRow01">
		<td colspan="4" align="right">

			 <table width="100%" cellpadding="1" cellspacing="0">

			 <tr class="TextHeader" align="center">
			<td width="5%"><cellbytelabel></cellbytelabel></td>
			<td width="6%"><cellbytelabel></cellbytelabel></td>
			<td width="5%"><cellbytelabel></cellbytelabel></td>
			<td width="6%"><cellbytelabel></cellbytelabel></td>
		<%if(facturar_a.trim().equals("")||!facturar_a.trim().equals("O")){%>
			<td width="4%"><cellbytelabel></cellbytelabel></td>
			<td width="4%"><cellbytelabel></cellbytelabel></td><%}%>
			<td width="21%"><cellbytelabel></cellbytelabel></td>
		<%if(facturar_a.trim().equals("")||!facturar_a.trim().equals("O")){%><td width="21%"><cellbytelabel></cellbytelabel></td><%}%>
			<td width="5%"><cellbytelabel></cellbytelabel></td>
		 <%if(facturar_a.trim().equals("")||!facturar_a.trim().equals("O")){%>
			<td width="5%" align="right"><cellbytelabel>Total</cellbytelabel>:</td><%}%>
			<td width="5%" align="right"><%=CmnMgr.getFormattedDecimal(""+totMonto)%></td>
			<td width="6%" align="right"><%=CmnMgr.getFormattedDecimal(""+totSaldo)%></td>
			<td width="2%">&nbsp;</td>
		</tr>
			 </table>

		</td>
		</tr>
<%}%>
</table>
</body>
</html>
<%
}
%>
