<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
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
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String consecutivo = request.getParameter("consecutivo");
String anio = request.getParameter("ea_ano");
String clase = request.getParameter("clase_comprob");
String mes = request.getParameter("mes");
String regType = request.getParameter("regType");
String estado = request.getParameter("estado");
String creadoPor = request.getParameter("creadoPor");

if (consecutivo == null) consecutivo = "";
if (anio == null) anio = "";
if (clase == null) clase = "";
if (mes == null) mes = "";
if (regType == null) regType = "";
if (estado == null) estado = "";
if (creadoPor == null) creadoPor = "";

String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
if (fg == null) fg = "";
if (fp == null) fp = "";
String date = CmnMgr.getCurrentDate("dd/mm/yyyy");
int iconHeight = 40;
int iconWidth = 40;
String cdsDet= "N";
try {cdsDet =java.util.ResourceBundle.getBundle("issi").getString("cdsDet");}catch(Exception e){ cdsDet = "N";}

if (request.getMethod().equalsIgnoreCase("GET")) {
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null) {
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	if (!anio.trim().equals("")) { sbFilter.append(" and a.ea_ano = "); sbFilter.append(anio); }
	if(request.getParameter("ea_ano") ==null) anio = date.substring(6,10);
	if (!consecutivo.trim().equals("")) { sbFilter.append(" and a.consecutivo = "); sbFilter.append(consecutivo); }
	if (!clase.trim().equals("")) { sbFilter.append(" and clase_comprob = "); sbFilter.append(clase); }
	if (!mes.trim().equals("")) { sbFilter.append(" and a.mes = "); sbFilter.append(mes); }
	if (!regType.trim().equals("")) { sbFilter.append(" and a.reg_type = '");sbFilter.append(regType);sbFilter.append("'"); }
	if (!estado.trim().equals("")) { sbFilter.append(" and a.status = '");sbFilter.append(estado);sbFilter.append("'"); }
	if (!creadoPor.trim().equals("")&&!creadoPor.trim().equals("DA")) { sbFilter.append(" and a.creado_por = '");sbFilter.append(creadoPor);sbFilter.append("'"); }
	if (!creadoPor.trim().equals("")&&creadoPor.trim().equals("DA")&&fg.equalsIgnoreCase("CD")) { sbFilter.append(" and exists (select null from tbl_con_registros_auxiliar where compania=a.compania and trans_id =a.consecutivo and trans_anio=a.ea_ano and estado='A') "); }

	String tableName = "";
	if (fg.equalsIgnoreCase("CD")||fg.equalsIgnoreCase("CS")) tableName = "tbl_con_encab_comprob";
	else if(fg.equals("PLA")) tableName = "tbl_pla_planilla_encabezado e,tbl_pla_pre_encab_comprob";
	if(fg.equals("PLA")) sbFilter.append(" and e.asconsecutivo(+) = a.consecutivo_comp and e.anio(+) = a.ea_ano and to_number(to_char(e.fecha_cheque(+),'mm')) = a.mes and e.cod_compania(+) = a.compania ");
	if (fg.equalsIgnoreCase("CS")){sbFilter.append(" and a.estado<>'I' and a.creado_por ='SP' ");}

	sbSql = new StringBuffer();
	sbSql.append("select distinct * from (select rownum as rn, a.* from (");
		sbSql.append("select a.ea_ano, ");
		if(fg.equals("PLA"))sbSql.append(" a.consecutivo_comp ");
		else sbSql.append(" a.consecutivo ");
		sbSql.append(" as consecutivo");
		if (fg.equalsIgnoreCase("CD"))sbSql.append(" ,(select count(*) from tbl_con_registros_auxiliar where compania=a.compania and trans_id =a.consecutivo and trans_anio=a.ea_ano and estado='A') regAuxiliar");
		else sbSql.append(" ,0 regAuxiliar");

		sbSql.append(", a.compania, decode(a.mes,1,'ENERO',2,'FEBRERO',3,'MARZO',4,'ABRIL',5,'MAYO',6,'JUNIO',7,'JULIO',8,'AGOSTO',9,'SEPTIEMBRE',10,'OCTUBRE',11,'NOVIEMBRE',12,'DICIEMBRE',13,'CIERRE ANUAL') as mes, a.mes as mes_cons, a.clase_comprob, a.descripcion, (select nombre_corto from tbl_con_clases_comprob where codigo_comprob = a.clase_comprob and tipo =decode('"+fg+"','PLA','P','C')) as comprob_desc, a.total_cr, a.total_db, nvl(a.n_doc,' ') as nDoc, to_char(a.fecha_sistema,'dd/mm/yyyy') as fechaSistema,a.status, a.usuario,nvl(a.usuario_creacion,a.usuario) as usuario_creacion, to_char(nvl(a.fecha_creacion,fecha_comp),'dd/mm/yyyy') as fecha_creacion, a.creado_por,(select estado from tbl_con_estado_anos where cod_cia = a.compania and ano =a.ea_ano) estadoAnio, a.estado,case when a.consecutivo < 0 or a.ea_ano < (select z.ano from tbl_con_estado_anos z where z.estado ='ACT' and z.cod_cia =a.compania)-1 then 'N' else 'S' end as anular,(select estatus from tbl_con_estado_meses where ano=a.ea_ano and cod_cia=a.compania and mes = a.mes) estadoMes,decode(a.status,'AP','APROBADO','PE','PENDIENTE','DE','DESAPROB.')||decode(a.status,'AP',decode(a.estado,'I','/AN.'),'') descStatus, (select report_path from tbl_con_clases_comprob where codigo_comprob = a.clase_comprob and tipo =decode('"+fg+"','PLA','P','C')) as reporteRes, (select report_path_det from tbl_con_clases_comprob where codigo_comprob = a.clase_comprob and tipo =decode('"+fg+"','PLA','P','C')) as reporteDet, (select usado_por from tbl_con_clases_comprob where codigo_comprob = a.clase_comprob and tipo =decode('"+fg+"','PLA','P','C')) as usado_por,to_char(fecha_desde,'dd/mm/yyyy') as fecha_desde,to_char(fecha_hasta,'dd/mm/yyyy') as fecha_hasta,  nvl(get_sec_comp_param(a.compania,'CON_RECEP_INCLU_ITBM'),'N') as inclTax ");
		if(!fg.equals("PLA"))sbSql.append(",case when a.estado = 'A' and a.status  in ('AP','PE') and tipo=1 then 'S' else 'N' end ");
		else sbSql.append(", 'N' ");
		sbSql.append(" as verReporte ");

		if (fg.equalsIgnoreCase("CD")||fg.equalsIgnoreCase("CS")) sbSql.append(", a.tipo");
		else sbSql.append(", 1 as tipo");
		if (fg.equalsIgnoreCase("CD")||fg.equalsIgnoreCase("CS")) sbSql.append(", a.reg_type as regType, decode(a.reg_type,'D','COMP. DIARIO','H','COMP. HIST.') regTypeDesc ");
		else sbSql.append(",'D' as regType,'PLANILLA' regTypeDesc");
		sbSql.append(" from ");
		sbSql.append(tableName);
		sbSql.append(" a where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(sbFilter);
		sbSql.append(" order by a.ea_ano desc, a.mes desc, a.consecutivo desc");
	sbSql.append(") a) where rn between ");
	sbSql.append(previousVal);
	sbSql.append(" and ");
	sbSql.append(nextVal);

	if(request.getParameter("ea_ano") !=null){
	al = SQLMgr.getDataList(sbSql);

	sbSql = new StringBuffer();
	sbSql.append("select count(*) count from ");
	sbSql.append(tableName);
	sbSql.append(" a where a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(sbFilter);
	rowCount = CmnMgr.getCount(sbSql.toString());
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
<script language="javascript">
document.title = 'Comprobante <%=(fg.equals("CD"))?"Diario":"Planilla"%> - '+document.title;
function add(regType){abrir_ventana('../contabilidad/reg_comp_diario.jsp?mode=add&fg=<%=fg%>&fp=<%=fp%>&tipo=1&regType='+regType);}
function edit(id,anio,tipo,regType,mode){
var i = document.form1.index.value;
var usadoPor = $("#usado_por"+i).val();
abrir_ventana('../contabilidad/reg_comp_diario.jsp?mode='+mode+'&no='+id+'&fg=<%=fg%>&fp=<%=fp%>&anio='+anio+'&tipo='+tipo+'&regType='+regType+'&usado_por='+usadoPor);}
function app(k,status,fp){var anio = eval('document.form1.anio'+k).value;var id = eval('document.form1.id'+k).value;var mes = eval('document.form1.mes'+k).value;var tipo = eval('document.form1.tipo'+k).value;var total_cr = eval('document.form1.total_cr'+k).value;var total_db = eval('document.form1.total_db'+k).value;var claseComprob = eval('document.form1.claseComprob'+k).value; var creado_por = eval('document.form1.creado_por'+k).value; var x=0; if(status !='DE'){	if(!hasDBData('<%=request.getContextPath()%>','tbl_con_estado_anos','ano='+anio+' and cod_cia=<%=(String) session.getAttribute("_companyId")%> and estado in (\'ACT\',\'TRS\')',''))	{		CBMSG.warning('Este año no existe o no está Activo o en Transicion!');x++;	}else if( claseComprob !='21' && claseComprob !='22' && claseComprob !='25' && status !='DE'){if(!hasDBData('<%=request.getContextPath()%>','tbl_con_estado_meses','ano='+anio+' and cod_cia=<%=(String) session.getAttribute("_companyId")%> and mes = '+mes+' and estatus=\'ACT\'','')){CBMSG.warning('Este mes no existe o no está Activo!');x++;}}if(total_db!=total_cr){CBMSG.warning('El Comprobante no está Balanceado');x++;}else if(total_db==total_cr&&total_db==0.00){CBMSG.warning('El Balance no puede ser igual a Cero (0)');x++;}}
	if(x==0){if(fp=='AP')showPopWin('../common/run_process.jsp?fp=COMPDIARIO&actType=50&docType=COMPDIARIO&docId='+id+'&docNo='+id+'&compania=<%=(String) session.getAttribute("_companyId")%>&anio='+anio+'&mes='+mes+'&tipo='+tipo+'&comprob='+claseComprob+'&creadoPor='+creado_por,winWidth*.75,winHeight*.60,null,null,'');
	else if(fp=='DE'&& '<%=fg%>'=='PLA'){showPopWin('../common/run_process.jsp?fp=COMPDIARIO&actType=58&docType=COMPDIARIO&docId='+id+'&docNo='+id+'&compania=<%=(String) session.getAttribute("_companyId")%>&anio='+anio+'&mes='+mes+'&tipo='+tipo+'&comprob='+claseComprob+'&creadoPor='+creado_por,winWidth*.75,winHeight*.60,null,null,'');
	}else if(fp=='DE'&& '<%=fg%>'!='PLA')showPopWin('../common/run_process.jsp?fp=COMPDIARIO&actType=51&docType=COMPDIARIO&docId='+id+'&docNo='+id+'&compania=<%=(String) session.getAttribute("_companyId")%>&anio='+anio+'&mes='+mes+'&tipo='+tipo+'&comprob='+claseComprob+'&creadoPor='+creado_por,winWidth*.75,winHeight*.60,null,null,'');
	else if(fp=='AN')showPopWin('../common/run_process.jsp?fp=COMPDIARIO&actType=52&docType=COMPDIARIO&docId='+id+'&docNo='+id+'&compania=<%=(String) session.getAttribute("_companyId")%>&anio='+anio+'&mes='+mes+'&tipo='+tipo+'&comprob='+claseComprob+'&creadoPor='+creado_por,winWidth*.75,winHeight*.60,null,null,'');}}
function cerrar(consecutivo,anio,mes,fg,tipo){var actType ='';if(fg=='AP')actType='6';else actType ='7';showPopWin('../common/run_process.jsp?fp=comp_hist&actType='+actType+'&docType=COMP_HIST&docId='+consecutivo+'&docNo='+consecutivo+'&anio='+anio+'&mes='+mes+'&tipo='+tipo,winWidth*.75,winHeight*.60,null,null,'');}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,300);}
function anularCH(anio,mes,id,tipo){if(confirm('Estimado usuario, está usted seguro de ANULAR el comprobante Historico # '+id+' del año '+anio+'!')){showPopWin('../common/run_process.jsp?fp=comp_hist&actType=50&docType=COMP_HIST&docId='+id+'&docNo='+id+'&anio='+anio+'&mes='+mes+'&compania=<%=(String) session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.60,null,null,'');}else CBMSG.warning('Proceso cancelado');}
function detalle(id,anio,tipo,clase){abrir_ventana('../contabilidad/ver_comp_diario.jsp?mode=view&no='+id+'&fg=<%=fg%>&fp=<%=fp%>&anio='+anio+'&tipo='+tipo+'&claseComp='+clase);}
function setIndex(k){document.form1.index.value=k;checkOne('form1','check',<%=al.size()%>,eval('document.form1.check'+k),0);}
function mouseOut(obj,option){var optDescObj=document.getElementById('optDesc');setoutc(obj,'ImageBorder');optDescObj.innerHTML='&nbsp;';}
function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 0:msg='Registrar Comprobante Diario';break;
		case 1:msg='Editar';break;
		case 2:msg='Aprobar Comprobante Diario';break;
		case 3:msg='Desaprobar Comprobante Diario';break;
		case 4:msg='Anular Comprobante Diario';break;
		case 5:msg='Ver';break;
		case 6:msg='Imprimir Comprobante Detallado';break;
		case 7:msg='Detalle Auxiliar';break;
		case 8:msg='Mapping de Cuentas';break;
		case 9:msg='Registrar Comprobante Historico';break;
		case 10:msg='Aprobar Comprobante Historico';break;
		case 11:msg='Desaprobar Comprobante Historico';break;
		case 12:msg='Anular Comprobante Historico';break;
		case 13:msg='Imprimir Comprobante Resumido';break;
		case 14:msg='Registrar Comprobante De Planilla';break;
		case 15:msg='Reporte Auxiliar Resumido';break;
		case 16:msg='Reporte Auxiliar Detallado';break;
		case 17:msg='Imprimir Comprobante Mensual';break;
		case 18:msg='Desaprobar Pre - Comprobante';break;
		case 20:msg='Imprimir Comprobante Detallado Excel';break;
	}
	setoverc(obj,'ImageBorderOver');
	optDescObj.innerHTML=msg;
	obj.alt=msg;
}
function goOption(option)
{
	if(option==0||option==9){if(option==0)add('D');else if(option==9)add('H');}
	else
	{
		if(option==undefined)CBMSG.warning('La opción no está definida todavía.\nPor favor consulte con su Administrador!');
		else
		{
			var k=document.form1.index.value;
			if(k=='')CBMSG.warning('Por favor seleccione un Comprobante antes de ejecutar una acción!');
			else
			{
				var anio = eval('document.form1.anio'+k).value;
				var mes = eval('document.form1.mes'+k).value;
				var id = eval('document.form1.id'+k).value;
				var tipo = eval('document.form1.tipo'+k).value;
				var regType = eval('document.form1.regType'+k).value;
				var estado = eval('document.form1.estado'+k).value;
				var status = eval('document.form1.status'+k).value;
				var stdAnio = eval('document.form1.estadoAnio'+k).value;
				var anular = eval('document.form1.anular'+k).value;
				var claseComprob = eval('document.form1.claseComprob'+k).value;
				var  descAnio = '';
				if(stdAnio=='CER')descAnio='CERRADO ';
				else if(stdAnio=='INA')descAnio='INACTIVO ';

				if(option==1){if(status=='PE'){if(tipo=='1')edit(id,anio,tipo,regType,'edit');else CBMSG.warning('Solo para Comprobante Original.');}else CBMSG.warning('El estado del registro Seleccionado, no permite está Accion');}
				else if(option==2||option==3||option==4||option==18)
				{
					if(regType.trim()=='D')
					{
						if(stdAnio.trim() !='CER' && stdAnio.trim() !='INA')
						{
							if(status.trim()=='PE')
							{
								if(option==2)app(k,'AP','AP');
								else if((option==3||option==18) && tipo=='1')app(k,'DE','DE');
							}
							else if(status.trim() =='AP' && estado.trim() =='A')
							{
								if(option==4||option==18)app(k,'AN','AN');
								else CBMSG.warning('Opcion invalida');
							}
							else CBMSG.warning('Estado de registro invalido para la Accion seleccionda!!');
						}
						else CBMSG.warning('Estado de año Invalido para está Accion - '+descAnio+'!!');
					}else CBMSG.warning('OPCION PARA COMPROBANTES DIARIOS');
				}
				else if(option==10||option==11||option==12)
				{
					 if(regType.trim()=='H')
					 {
						if((stdAnio.trim() =='CER' || stdAnio.trim() =='TRS'))
						{
							if(status.trim()=='PE')
							{
								if(option==10)cerrar(id,anio,mes,'AP',tipo);
								else if(option==11)cerrar(id,anio,mes,'RE',tipo);
							}
							else if(status.trim()=='AP' && estado.trim() =='A')
							{
								 if(option==12  && anular.trim()=='S')anularCH(anio,mes,id,tipo);
							}
							else CBMSG.warning('Estado de registro invalido para la Accion seleccionda!!');
						}else CBMSG.warning('Estado de año Invalido para está Accion - '+descAnio+'!!');
					}else CBMSG.warning('OPCION PARA COMPROBANTES HISTORICOS');
				}
				else if(option==5)edit(id,anio,tipo,regType,'view');
				else if(option==6)printComprob(anio,mes,id,tipo,regType,'DET',claseComprob);
				else if(option==13)printComprob(anio,mes,id,tipo,regType,'RES',claseComprob);
				else if(option==14){if(status.trim()=='PE'){if(stdAnio.trim() !='CER' && stdAnio.trim() !='INA')edit(id,anio,tipo,regType,'add');else CBMSG.warning('El año del comprobante no está activo.');}else if(status.trim()!='PE'){ CBMSG.warning('El comprobante ya fue Registrado!');}else if(status.trim()=='DE') CBMSG.warning('El comprobante fue Desaprobado!'); }
				else if(option==15)printAuxiliar(anio,id,'RES',k);
				else if(option==16)printAuxiliar(anio,id,'DET',k);
				else if(option==17)printComprob(anio,mes,id,tipo,regType,'MES',claseComprob);
				else if(option==20)printComprob(anio,mes,id,tipo,regType,'DET_EXCEL',claseComprob);
				//else if(option==7)printComprob(anio,mes,id,tipo,regType);
			}
		}
	}
}
function printComprob(anio,mes,id,tipo,regType,tipoRep,clase){
    if(tipoRep=='DET')abrir_ventana('../contabilidad/print_list_comprobante_mensual.jsp?fp=listComp&anio='+anio+'&no='+id+'&tipo='+tipo+'&fg=<%=fg%>&regType='+regType);
    else if(tipoRep=='DET_EXCEL')abrir_ventana('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_comprobante_plani_detallado.rptdesign&p_anio='+anio+'&p_consec_comp='+id);
    else if(tipoRep=='RES')abrir_ventana('../contabilidad/print_comprob_resumido.jsp?fp=listComp&anio='+anio+'&no='+id+'&tipo='+tipo+'&fg=<%=fg%>&regType='+regType);
    else if(tipoRep=='MES')abrir_ventana('../contabilidad/print_comprob_resumido.jsp?fp=mens&anio='+anio+'&mes='+mes+'&tipo='+tipo+'&fg=<%=fg%>&regType='+regType+'&clase='+clase);
}
function printAuxiliar(anio,id,fg,k)
{
 var pathRes = eval('document.form1.reporteRes'+k).value;
 var pathDet = eval('document.form1.reporteDet'+k).value;
 var path='';
 var fDesde	= eval('document.form1.fecha_desde'+k).value;
 var fHasta = eval('document.form1.fecha_hasta'+k).value;
 var inclTax = eval('document.form1.inclTax'+k).value;
 var fdArray = fDesde.split("/");
 var fhArray = fHasta.split("/");
 var claseComprob = eval('document.form1.claseComprob'+k).value;
 var verReporte = eval('document.form1.verReporte'+k).value;

 if (verReporte=='S'){
 if(claseComprob!='3'){
	fDesde = fdArray[2]+"-"+fdArray[1]+"-"+fdArray[0];
	fHasta = fhArray[2]+"-"+fhArray[1]+"-"+fhArray[0];}

 if(fg=='DET')path=pathDet;
 else path=pathRes;
	if(path=='')CBMSG.warning('EL TIPO DE COMPROBANTE NO TIENE DEFINIDO REPORTE DE AUXILIAR!!!');
	else abrir_ventana(path+'&fDesde='+fDesde+'&fHasta='+fHasta+'&pAnio='+anio+'&pConsecutivo='+id+'&pInclTax='+inclTax+'&pCds=<%=cdsDet%>&pCentro_servicio=-4');
}
else  CBMSG.warning('SOLO PARA COMPROBANTES ACTIVOS, APROBADOS O PENDIENTES, QUE NO SEAN PRODUCTO DE UN ANULACION!!!');
}

$(function(){
	$(".observAyuda, .motivoAnul").tooltip({
	content: function () {

		var $i = $(this).data("i");
		var $type = $(this).data("type");
		var $title = $($(this).prop('title'));
		var $content;

		if($type == "1" ) $content = $("#observAyudaCont"+$i).val();

		var $cleanContent = $($content).text();
		if (!$cleanContent) $content = "";
		return $content;
	}
	,track: true
	,position: { my: "left+15 center", at: "right center", collision: "flipfit" }
	});
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - REGISTRO COMPROBANTE"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right">&nbsp;
	<div id="optDesc" class="TextInfo Text10">&nbsp;</div>
		<%if(!fg.trim().equals("PLA")){%>
		<authtype type='3'><a href="javascript:goOption(0)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,0)" onMouseOut="javascript:mouseOut(this,0)" src="../images/add.png"></a></authtype>
		<authtype type='52'><a href="javascript:goOption(9)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,9)" onMouseOut="javascript:mouseOut(this,9)" src="../images/plus_ch.png"></a></authtype>
		<authtype type='4'><a href="javascript:goOption(1)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/editar.png"></a></authtype>
		<authtype type='1'><a href="javascript:goOption(5)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,5)" onMouseOut="javascript:mouseOut(this,5)"  src="../images/ver.png"></a></authtype>
		<authtype type='2'><a href="javascript:goOption(6)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,6)" onMouseOut="javascript:mouseOut(this,6)" src="../images/print_d.png"></a></authtype>
		<authtype type='2'><a href="javascript:goOption(13)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,13)" onMouseOut="javascript:mouseOut(this,13)" src="../images/print_r.png"></a></authtype>
		<authtype type='2'><a href="javascript:goOption(17)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,17)" onMouseOut="javascript:mouseOut(this,17)" src="../images/print.png"></a></authtype>
		<authtype type='7'><a href="javascript:goOption(3)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/x.png"></a></authtype>
		<authtype type='6'><a href="javascript:goOption(2)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/check_mark.png"></a></authtype>
		<authtype type='50'><a href="javascript:goOption(4)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,4)" onMouseOut="javascript:mouseOut(this,4)" src="../images/anular.png"></a></authtype>
		<authtype type='54'><a href="javascript:goOption(11)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,11)" onMouseOut="javascript:mouseOut(this,11)" src="../images/x_ch.png"></a></authtype>
		<authtype type='53'><a href="javascript:goOption(10)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,10)" onMouseOut="javascript:mouseOut(this,10)" src="../images/check_mark_ch.png"></a></authtype>
		<authtype type='55'><a href="javascript:goOption(12)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,12)" onMouseOut="javascript:mouseOut(this,12)" src="../images/cancel_ch.png"></a></authtype>
		<authtype type='56'><a href="javascript:goOption(15)" class="hint hint--top" data-hint="Reporte de Auxiliar Resumido"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,15)" onMouseOut="javascript:mouseOut(this,15)" src="../images/analisis_y_facturacion.png"></a></authtype>
		<authtype type='57'><a href="javascript:goOption(16)" class="hint hint--top" data-hint="Reporte de Auxiliar Detallado"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,16)" onMouseOut="javascript:mouseOut(this,16)" src="../images/analisis_y_facturacion.png"></a></authtype>
		<%}else{%>
		<authtype type='58'><a href="javascript:goOption(18)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,18)" onMouseOut="javascript:mouseOut(this,18)" src="../images/x.png"></a></authtype>
		<authtype type='1'><a href="javascript:goOption(5)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,5)" onMouseOut="javascript:mouseOut(this,5)"  src="../images/ver.png"></a></authtype>
		<authtype type='2'><a href="javascript:goOption(6)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,6)" onMouseOut="javascript:mouseOut(this,6)" src="../images/print_d.png"></a></authtype>
		<authtype type='2'><a href="javascript:goOption(20)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,20)" onMouseOut="javascript:mouseOut(this,20)" src="../images/excel.png"></a></authtype>
		<authtype type='51'><a href="javascript:goOption(14)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,14)" onMouseOut="javascript:mouseOut(this,14)" src="../images/plus_cp.png"></a></authtype>
		<%}%>
	</td>
</tr>
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="0" cellspacing="0">
		<tr class="TextFilter">
<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>

			<td>
				AñO
				<%=fb.intBox("ea_ano",anio,false,false,false,5)%>
				MES:
				<%=fb.select("mes","1=Enero,2=Febrero,3=Marzo,4=Abril,5=Mayo,6=Junio,7=Julio,8=Agosto,9=Septiembre,10=Octubre,11=Noviembre,12=Diciembre,13=Cierre Anual",mes,false,false,0,"Text10",null,null,null,"T")%>
				ID
				<%=fb.intBox("consecutivo",consecutivo,false,false,false,7)%>
				Estado:<%=fb.select("estado","PE=PENDIENTE"+((!fg.trim().equals("PLA"))?",DE=DESAPROBADO":"")+",AP=APROBADO",estado,false,false,0,"Text10",null,null,null,"T")%>
				Clase
				<%=fb.select(ConMgr.getConnection(), "select codigo_comprob,codigo_comprob||' - '||substr(descripcion,1,65) as descripcion from tbl_con_clases_comprob where tipo="+((!fg.trim().equals("PLA"))?"'C'":"'P'"),"clase_comprob",clase,false,false,0,"Text10",null,null,null,"S")%>
				T. Registro:<%=fb.select("regType","D=DIARIO"+((!fg.trim().equals("PLA"))?",H=HISTORICO":""),regType,false,false,0,"Text10",null,null,null,"T")%>
				<%=fb.select("creadoPor","SP=PROCESO AUTOMATICO,RCM=REGISTRADO MANUAL,RP=REGISTROS DE PLANILLA,DA=COMPROB. CON AUXILIAR",creadoPor,false,false,0,"Text10",null,null,null,"T")%>
				<%=fb.submit("go","Ir")%>
			</td>
<%=fb.formEnd()%>

		</tr>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("ea_ano",anio)%>
<%=fb.hidden("consecutivo",consecutivo)%>
<%=fb.hidden("clase_comprob",clase)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("regType",regType)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("creadoPor",creadoPor)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("ea_ano",anio)%>
<%=fb.hidden("consecutivo",consecutivo)%>
<%=fb.hidden("clase_comprob",clase)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("regType",regType)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("creadoPor",creadoPor)%>
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
<%fb = new FormBean("form1",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("index","")%>
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="3%">A&ntilde;o</td>
			<td width="6%">Id</td>
			<td width="7%">Mes</td>
			<td width="6%">F. Creaci&oacute;n</td>
			<td width="7%">U. Creaci&oacute;n</td>
			<td width="21%">Descripci&oacute;n</td>
			<td width="18%">Tipo Comprob.</td>
			<td width="8%">Total DB</td>
			<td width="8%">Total CR</td>
			<td width="7%">T. Registro</td>
			<td width="8%">Estado</td>
			<td width="1%">&nbsp;</td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("anio"+i,cdo.getColValue("ea_ano"))%>
		<%=fb.hidden("id"+i,cdo.getColValue("consecutivo"))%>
		<%=fb.hidden("mes"+i,cdo.getColValue("mes_cons"))%>
		<%=fb.hidden("tipo"+i,cdo.getColValue("tipo"))%>
		<%=fb.hidden("total_cr"+i,cdo.getColValue("total_cr"))%>
		<%=fb.hidden("total_db"+i,cdo.getColValue("total_db"))%>
		<%=fb.hidden("claseComprob"+i,cdo.getColValue("clase_comprob"))%>
		<%=fb.hidden("creado_por"+i,cdo.getColValue("creado_por"))%>
		<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
		<%=fb.hidden("status"+i,cdo.getColValue("status"))%>
		<%=fb.hidden("anular"+i,cdo.getColValue("anular"))%>
		<%=fb.hidden("estadoAnio"+i,cdo.getColValue("estadoAnio"))%>
		<%=fb.hidden("estadoMes"+i,cdo.getColValue("estadoMes"))%>
		<%=fb.hidden("regType"+i,cdo.getColValue("regType"))%>
		<%=fb.hidden("reporteRes"+i,cdo.getColValue("reporteRes"))%>
		<%=fb.hidden("reporteDet"+i,cdo.getColValue("reporteDet"))%>
		<%=fb.hidden("fecha_desde"+i,cdo.getColValue("fecha_desde"))%>
		<%=fb.hidden("fecha_hasta"+i,cdo.getColValue("fecha_hasta"))%>
		<%=fb.hidden("inclTax"+i,cdo.getColValue("inclTax"))%>
		<%=fb.hidden("verReporte"+i,cdo.getColValue("verReporte"))%>
		<%=fb.hidden("usado_por"+i,cdo.getColValue("usado_por"))%>
		<%=fb.hidden("observAyudaCont"+i,"<label class='observAyudaCont' style='font-size:11px'>"+(cdo.getColValue("regAuxiliar").trim().equals("0")?"":"COMPROBANTE TIENE REGISTROS DE AUX. REGISTRADO")+"</label>")%>

		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("ea_ano")%></td>
			<td align="center"><%if(!fg.trim().equals("PLA")){%><a href="javascript:printComprob(<%=cdo.getColValue("ea_ano")%>,<%=cdo.getColValue("mes_cons")%>,<%=cdo.getColValue("consecutivo")%>,<%=cdo.getColValue("tipo")%>,'<%=cdo.getColValue("regType")%>','DET','')"><%}%><%=cdo.getColValue("consecutivo")%></a></td>
			<td align="center"><%=cdo.getColValue("mes")%></td>
			<td align="center"><%=cdo.getColValue("fecha_creacion")%></td>
			<td align="center"><%=cdo.getColValue("usuario_creacion")%></td>
			<td align="left"><%=cdo.getColValue("descripcion")%>-<%=cdo.getColValue("comprob_desc")%></td>
			<td align="left"><span class="observAyuda" title="" data-i="<%=i%>" data-type="1"><%=cdo.getColValue("comprob_desc")%>

			<%if(!cdo.getColValue("regAuxiliar").trim().equals("0")){%><label  class="<%=color%>"><label class="RedTextBold">&nbsp;REG. AUX..&nbsp;</label></label><%}%>			</span>
			</td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("total_db"))%>&nbsp;</td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("total_cr"))%>&nbsp;</td>
			<td align="center"><%=cdo.getColValue("regTypeDesc")%></td>
			<td align="center">
			<%if(cdo.getColValue("status").equals("DE")){%><label  class="<%=color%>"><label class="RedTextBold">&nbsp;<%}%><%=cdo.getColValue("descStatus")%> <%if(cdo.getColValue("status").equals("DE")){%>&nbsp;</label></label><%}%>

			</td>
			<td align="center"><%=fb.checkbox("check"+i,"",false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%></td>
		</tr>
<%}%>
		</table>
<%=fb.formEnd()%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("ea_ano",anio)%>
<%=fb.hidden("consecutivo",consecutivo)%>
<%=fb.hidden("clase_comprob",clase)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("regType",regType)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("creadoPor",creadoPor)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("ea_ano",anio)%>
<%=fb.hidden("consecutivo",consecutivo)%>
<%=fb.hidden("clase_comprob",clase)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("regType",regType)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("creadoPor",creadoPor)%>
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
