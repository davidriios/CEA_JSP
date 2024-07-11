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
fp
null or blank --> default
all           -->
fp = ARC aplicar recibos desde cobros
fp = CSR consulta de recibos
fp = PM  Recibos de plan medico
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
String tipoCliente = request.getParameter("tipoCliente");
String fp = request.getParameter("fp");
String tipoClienteX = request.getParameter("tipoClienteX");

int iconHeight = 48;
int iconWidth = 48;
if (tipoCliente == null) tipoCliente = "";
if (fp == null) fp = "";
if (tipoClienteX == null) tipoClienteX = "";

if (fp.trim().equals("")) {

	if (tipoCliente.trim().equals("")) throw new Exception("El Tipo de Recibo no es válido. Por favor intente nuevamente!");
	else if (tipoCliente.equalsIgnoreCase("A")) { sbFilter.append(" and a.tipo_cliente = 'O' and a.cliente_alq = 'S'"); }
	else if (tipoCliente.equalsIgnoreCase("O")) { sbFilter.append(" and a.tipo_cliente = 'O' and nvl(a.cliente_alq,'N') = 'N'"); }
	else { sbFilter.append(" and a.tipo_cliente = '"); sbFilter.append(tipoCliente.toUpperCase()); sbFilter.append("'"); }

} else {

	if (!tipoClienteX.trim().equals("")) { if(tipoClienteX.trim().equals("A")){sbFilter.append(" and a.cliente_alq = 'S' and a.tipo_cliente = 'O' "); }else{ sbFilter.append(" and a.tipo_cliente = '"); sbFilter.append(tipoClienteX.toUpperCase()); sbFilter.append("' and nvl(a.cliente_alq,'N') = 'N'");} }
	
	if(fp.equals("PM") && tipoCliente.equals("O")){
		sbFilter.append(" and a.tipo_cliente = 'O' and to_char(ref_type) = (select get_sec_comp_param(");
		sbFilter.append((String) session.getAttribute("_companyId"));
		sbFilter.append(", 'TIPO_CLTE_PLAN_MEDICO') from dual)");
		sbFilter.append(" and a.xtra2 = -1");
	}

}

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

	String recibo = request.getParameter("recibo");
	String nombre = request.getParameter("nombre");
	String nombreAdicional = request.getParameter("nombreAdicional");
	String caja = request.getParameter("caja");
	String fecha = request.getParameter("fecha");
	String recStatus = request.getParameter("recStatus");
	String codCliente = request.getParameter("codCliente");
	String fechaHasta = request.getParameter("fechaHasta");
	String sPorAplicar = request.getParameter("por_aplicar");
	String tipoRef = request.getParameter("tipoRef");
	String tipoOtro = request.getParameter("tipoOtro");
	String refer_to = request.getParameter("refer_to");
 	String usarFt = request.getParameter("usarFt");
 	String liberado = request.getParameter("liberado");
 	String fAnulaDesde = request.getParameter("fAnulaDesde");
 	String fAnulaHasta = request.getParameter("fAnulaHasta");
 	
	if (recibo == null) recibo = "";
	if (nombre == null) nombre = "";
	if (nombreAdicional == null) nombreAdicional = "";
	if (caja == null) caja = "";
	if (fecha == null) fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
	if (fechaHasta == null) fechaHasta = "";
	if (sPorAplicar==null) sPorAplicar = "";
	if (recStatus == null) if (fp.equalsIgnoreCase("ADMIN")) recStatus = "A"; else recStatus = "";
	if (codCliente == null) codCliente = "";
	if (tipoRef == null) tipoRef = "";
	if (tipoOtro == null) tipoOtro = "";
	if (refer_to == null) refer_to = "";
 	if (usarFt == null)usarFt="";
 	if (liberado == null) liberado = "";
 	if (fAnulaDesde == null) fAnulaDesde = "";
 	if (fAnulaHasta == null) fAnulaHasta = "";
 	
	if (!recibo.trim().equals("")) { sbFilter.append(" and upper(a.recibo) like '%"); sbFilter.append(recibo.toUpperCase()); sbFilter.append("%'"); }
	if (!nombre.trim().equals("")) { sbFilter.append(" and upper(a.nombre) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
	if (!nombreAdicional.trim().equals("")) { sbFilter.append(" and upper(a.nombre_adicional) like '%"); sbFilter.append(nombreAdicional.toUpperCase()); sbFilter.append("%'"); }
	if (caja.trim().equals("")) { if (!UserDet.getUserProfile().contains("0") && fp.trim().equals("")) { sbFilter.append(" and a.caja in ("); sbFilter.append(session.getAttribute("_codCaja")); sbFilter.append(")"); } }
	else { sbFilter.append(" and a.caja in ("); sbFilter.append(caja); sbFilter.append(")"); }
	if(fechaHasta.trim().equals("")){if(!fecha.trim().equals("")){sbFilter.append(" and a.fecha = to_date('"); sbFilter.append(fecha); sbFilter.append("','dd/mm/yyyy')");}}
	else {if(usarFt.trim().equals("")){ sbFilter.append(" and a.fecha >= to_date('"); sbFilter.append(fecha); sbFilter.append("','dd/mm/yyyy')"); }}
	if(!fAnulaDesde.trim().equals("")){sbFilter.append(" and trunc(a.fecha_anulacion) >= to_date('"); sbFilter.append(fAnulaDesde); sbFilter.append("','dd/mm/yyyy')");}
	if(!fAnulaHasta.trim().equals("")){sbFilter.append(" and trunc(a.fecha_anulacion) <= to_date('"); sbFilter.append(fAnulaHasta); sbFilter.append("','dd/mm/yyyy')");}
	if(usarFt.trim().equals(""))if(!fechaHasta.trim().equals("")){ sbFilter.append(" and a.fecha <= to_date('"); sbFilter.append(fechaHasta); sbFilter.append("','dd/mm/yyyy')");}
	if (!recStatus.trim().equals("")) { sbFilter.append(" and a.rec_status = '"); sbFilter.append(recStatus); sbFilter.append("'"); }
	if (!codCliente.trim().equals("")) { sbFilter.append(" and decode(a.tipo_cliente,'P',a.pac_id,'E',a.codigo_empresa,a.ref_id)= "); sbFilter.append(codCliente); sbFilter.append(""); }
	if (!tipoRef.trim().equals("")) { sbFilter.append(" and a.ref_type = "); sbFilter.append(tipoRef); }
	if (!tipoOtro.trim().equals("")) { sbFilter.append(" and exists ( select null from tbl_cxc_cliente_particular where compania = a.compania and codigo = a.ref_id and tipo_cliente ="); sbFilter.append(tipoOtro);sbFilter.append(") "); }
	if(usarFt.trim().equals("S") && (!fechaHasta.trim().equals("")||!fecha.trim().equals("")))
	{
		sbFilter.append(" and exists ( select null from tbl_cja_turnos_x_cajas ct where ct.compania = a.compania and ct.cod_turno = a.turno and ct.cod_caja = a.caja ");
		if(!fecha.trim().equals("")){sbFilter.append(" and ct.fecha_creacion >= to_date('"); sbFilter.append(fecha); sbFilter.append("','dd/mm/yyyy')");}
		if(!fechaHasta.trim().equals("")){ sbFilter.append(" and ct.fecha_creacion <= to_date('"); sbFilter.append(fechaHasta); sbFilter.append("','dd/mm/yyyy')");}
		 sbFilter.append("  ) ");
	}
	//if (request.getParameter("recibo") != null)
	{
		
		if (!sPorAplicar.trim().equals("")){
		   sbSql.append("select aaa.* from ( ");
		} else if (!liberado.trim().equals("")){
		   sbSql.append("select aaa.* from ( ");
		}
		sbSql.append("select a.compania, a.codigo, a.recibo, a.anio, a.caja, decode(a.tipo_cliente,'O',decode(a.cliente_alq,'S','A',a.tipo_cliente),tipo_cliente)tipo_cliente, a.codigo_paciente, a.pago_total, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.descripcion, a.rec_impreso, a.rec_status, decode(a.rec_status,'A','ACTIVO','I','ANULADO',a.rec_status) as estado, a.nombre, a.nombre_adicional");
		sbSql.append(", (select nvl(sum(monto),0) from tbl_cja_detalle_pago where compania = a.compania and tran_anio = a.anio and codigo_transaccion = a.codigo) as aplicado");
		sbSql.append(", (select nvl(sum(case when z.tipo_ajuste not in (select column_value  from table( select split((select get_sec_comp_param(z.compania,'CJA_TP_AJ_REC') from dual),',') from dual  )) then decode(z.lado_mov,'D',-z.monto,'C',z.monto) else 0 end ),0) as ajuste from vw_con_adjustment_gral z, tbl_fac_tipo_ajuste y where z.recibo = a.recibo and z.compania = a.compania and z.factura is null and z.tipo_doc = 'R' and z.tipo_ajuste = y.codigo and z.compania = y.compania and y.group_type in ('H','D')) as ajustado, nvl(a.tipo_rec,'M') as tipoRec, a.ref_type, a.ref_id, a.turno, a.turno_anulacion, a.sub_ref_id, a.consecutivo, a.anio_comprob");
		sbSql.append(" from tbl_cja_transaccion_pago a");
		sbSql.append(" where a.compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(sbFilter);
		if (!liberado.trim().equals("")){
		   sbSql.append(" and exists (select null from tbl_cja_detalle_pago dp where dp.compania = a.compania and dp.tran_anio = a.anio and dp.codigo_transaccion = a.codigo and dp.fac_codigo is not null)");
		}
		sbSql.append(" order by a.anio desc, a.codigo desc");
		
		if (!sPorAplicar.trim().equals("")){
		   sbSql.append(")aaa where (aaa.pago_total - aaa.aplicado + aaa.ajustado) <> 0 ");
		} else if (!liberado.trim().equals("")){
		   sbSql.append(")aaa where aaa.aplicado = 0");
		}
		   
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
		//rowCount = CmnMgr.getCount("select count(*) from tbl_cja_transaccion_pago a where a.compania="+(String) session.getAttribute("_companyId")+sbFilter);
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
var gTitleAlert = '<%=java.util.ResourceBundle.getBundle("issi").getString("windowTitle")%>';
document.title = 'LISTADO DE RECIBOS - '+document.title;
function add(){abrir_ventana('../caja/reg_recibo.jsp?tipoCliente=<%=tipoCliente%>&mode=add&fp=<%=fp%>');}
function view(codigo,compania,anio,tCliente){var tipoCliente ='<%=(fp.trim().equals(""))?tipoCliente:tipoClienteX%>';if(tipoCliente=='')tipoCliente=tCliente;abrir_ventana('../caja/reg_recibo.jsp?mode=view&tipoCliente='+tipoCliente+'&codigo='+codigo+'&compania='+compania+'&anio='+anio+'&fp=<%=fp%>');}
function printList(opt){
	if(!opt) abrir_ventana('../caja/print_list_recibo.jsp?tipoCliente=<%=(fp.trim().equals(""))?tipoCliente:tipoClienteX%>&appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>&por_aplicar=<%=sPorAplicar%>&fp=<%=fp%>&fechaDesde=<%=fecha%>&fechaHasta=<%=fechaHasta%>');
	else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=caja/print_list_recibo.rptdesign&tipoCliente=<%=(fp.trim().equals(""))?tipoCliente:tipoClienteX%>&appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>&por_aplicar=<%=sPorAplicar%>&fp=<%=fp%>&fechaDesde=<%=fecha%>&fechaHasta=<%=fechaHasta%>&pCtrlHeader=true');
}

function printRecibo(codigo,compania,anio,tipoRec){
	if(tipoRec=='M')
		abrir_ventana('../caja/print_recibo_pago.jsp?fp=recibos&tipoCliente=<%=(fp.trim().equals(""))?tipoCliente:tipoClienteX%>&codigo='+codigo+'&compania='+compania+'&anio='+anio);
	else {
	  var printed = getDBData('<%=request.getContextPath()%>',"nvl(rec_impreso,'N')",'tbl_cja_transaccion_pago',"codigo = "+codigo+" and compania = "+compania+" and anio = "+anio);
	  
	  if (printed == "N"){
	    CBMSG.alert("Señor usuario, una vez cierre este documento las próximas impresiones saldrán como COPIA.",{cb:function(r){
		   if (r=="Ok") __printRecibo(codigo,compania,anio,tipoRec);
		}});
	  }else __printRecibo(codigo,compania,anio,tipoRec,"P")
	}
	
	function __printRecibo(codigo,compania,anio,tipoRec,status){
	  abrir_ventana('../caja/print_recibo_pagoAuto.jsp?fp=recibos&tipoCliente=<%=(fp.trim().equals(""))?tipoCliente:tipoClienteX%>&codigo='+codigo+'&compania='+compania+'&anio='+anio+'&showColor='+(status||""));
	}
}
// 
function anulate(codigo,compania,anio,caja,recibo){var turno=getDBData('<%=request.getContextPath()%>','a.cod_turno','tbl_cja_turnos_x_cajas a, tbl_cja_cajas b','a.compania = b.compania and a.cod_caja = b.codigo and a.compania = '+compania+' and a.cod_caja = '+caja+' and a.estatus = \'A\' and b.ip = \'<%=request.getRemoteAddr()%>\'');if(turno==undefined||turno==null||turno.trim()==''){CBMSG.warning('El recibo que intenta anular no fue creado en esta caja, favor dirigirse a la caja donde se origino el mismo!');return false;}showPopWin('../common/run_process.jsp?fp=recibos&actType=7&docType=REC&docId='+codigo+'&docNo='+recibo+'&compania='+compania+'&anio='+anio+'&turno='+turno+'&tipoCliente=<%=(fp.trim().equals(""))?tipoCliente:tipoClienteX%>',winWidth*.75,winHeight*.65,null,null,'');}
function anulateSup(codigo,compania,anio,caja,recibo){showPopWin('../common/run_process.jsp?fp=recibos&actType=56&docType=REC&docId='+codigo+'&docNo='+recibo+'&compania='+compania+'&anio='+anio+'&tipoCliente=<%=(fp.trim().equals(""))?tipoCliente:tipoClienteX%>',winWidth*.75,winHeight*.65,null,null,'');}
function aplicar(codigo,compania,anio,tCliente){var tipoCliente ='<%=(fp.trim().equals(""))?tipoCliente:tipoClienteX%>';if(tipoCliente=='')tipoCliente=tCliente;abrir_ventana('../caja/reg_recibo.jsp?fg=A&mode=edit&tipoCliente='+tipoCliente+'&codigo='+codigo+'&compania='+compania+'&anio='+anio+'&fp=<%=fp%>');}

function aplicarTxt(codigo,recibo,anio,tCliente){var tipoCliente ='<%=(fp.trim().equals(""))?tipoCliente:tipoClienteX%>';if(tipoCliente=='')tipoCliente=tCliente;
showPopWin('../caja/param_aplicar_rec_txt.jsp?tipoCliente='+tipoCliente+'&codigo='+codigo+'&anio='+anio+'&recibo='+recibo+'&fp=<%=fp%>',winWidth*.95,_contentHeight*.75,null,null,'');
}
function ajusteRec(recibo,ref_type,ref_id){abrir_ventana1('../facturacion/notas_ajustes_config.jsp?fg=AR&recibo='+recibo+'&ref_type='+ref_type+'&ref_id='+ref_id);}
function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 0:msg='Registrar Recibo';break;
		case 1:msg='Ver Recibo';break;
		case 2:msg='Imprimir Recibo';break;
		case 3:msg='Anular Recibo';break;
		case 4:msg='Aplicar Recibo';break;
		case 5:msg='Distribuir Recibo';break;
		case 6:msg='Liberar Recibo (Admision - Facturas sin distribuir)';break;
		case 7:msg='Ajuste Automatico';break;
		case 8:msg='Consulta De Ajuste,aplicacion y distribucion del Recibos';break;
		case 9:msg='Anular Recibo *SUPERVISOR*';break;
		case 10:msg='Ajustar Recibo';break;
		case 11:msg='Imprimir Recibo (Pre-Impreso)';break;
		case 12:msg='Recibo Reemplazable (Solo para ANULADOS fuera de Turno)';break;
		case 13:msg='Abrir Cajon';break;
		case 14:msg='Cambiar Cliente';break;
		case 15:msg='Cambiar Tipo de Cliente';break;
		case 16:msg='Aplicar Recibos (txt) ';break;
	}
	setoverc(obj,'ImageBorderOver');
	optDescObj.innerHTML=msg;
	obj.alt=msg;
}
function mouseOut(obj,option){var optDescObj=document.getElementById('optDesc');setoutc(obj,'ImageBorder');optDescObj.innerHTML='&nbsp;';}
function setIndex(k){if(document.form01.index.value!=k){document.form01.index.value=k;}}
function goOption(option)
{
	if(option==undefined)CBMSG.warning('La opción no está definida todavía.\nPor favor consulte con su Administrador!');
	else if(option==0)add();
	else if(option==13)showPopWin('../common/execute_fiscal_cmds.jsp?f_command=0',winWidth*.55,winHeight*.30,null,null,'');
	else
	{
		var k=parseInt(document.form01.index.value,10);
		if(k==-1)CBMSG.warning('Por favor seleccione un recibo antes de ejecutar una acción!');
		else{
		var compania=eval('document.form01.compania'+k).value;
		var anio=eval('document.form01.anio'+k).value;
		var codigo=eval('document.form01.codigo'+k).value;
		var caja=eval('document.form01.caja'+k).value;
		var recibo=eval('document.form01.recibo'+k).value;
		var status=eval('document.form01.rec_status'+k).value;
		var impreso=eval('document.form01.rec_impreso'+k).value;
		var tipoRec=eval('document.form01.tipo_rec'+k).value;
		var ref_type=eval('document.form01.ref_type'+k).value;
		var ref_id=eval('document.form01.ref_id'+k).value;
		var turno=eval('document.form01.turno'+k).value;
		var turnoAnula=eval('document.form01.turnoAnula'+k).value;
		var tipoCliente = eval('document.form01.tipoCliente'+k).value;
		var sub_ref_id = eval('document.form01.sub_ref_id'+k).value;
		var fecha = eval('document.form01.fecha'+k).value;
		var consecutivo = eval('document.form01.consecutivo'+k).value;
		var anio_comprob = eval('document.form01.anio_comprob'+k).value;
		if(option==1){view(codigo,compania,anio,tipoCliente);}
		else if(option==2){if(isValidStatus4Opt(status))printRecibo(codigo,compania,anio,tipoRec);}
		else if(option==3){if(isValidStatus4Opt(status))anulate(codigo,compania,anio,caja,recibo);}
		else if(option==4){/*if('<%=(fp.trim().equals(""))?tipoCliente:tipoClienteX%>'=='P' ||'<%=(fp.trim().equals(""))?tipoCliente:tipoClienteX%>'=='E' ||'<%=(fp.trim().equals(""))?tipoCliente:tipoClienteX%>'=='O')*/
		if(tipoCliente=='P'||tipoCliente=='E'||tipoCliente=='O'){if(isValidStatus4Opt(status))aplicar(codigo,compania,anio,tipoCliente);}else CBMSG.warning('Solo para recibos de Paciente y Empresas')}
		else if(option==5){if(isValidStatus4Opt(status))distribuir(codigo,compania,anio,tipoCliente);}
		else if(option==6){if(isValidStatus4Opt(status))liberar(codigo,compania,anio,recibo,tipoCliente);}
		else if(option==7){if(isValidStatus4Opt(status))ajusteAutomatico(codigo,compania,anio,tipoCliente);}
		else if(option==8){/*if(isValidStatus4Opt(status))*/ajusteRecibos(recibo);}
		else if(option==9){if(isValidStatus4Opt(status))anulateSup(codigo,compania,anio,caja,recibo);}
		else if(option==10){if(isValidStatus4Opt(status))ajusteRec(recibo,ref_type,ref_id);}
		else if(option==11){if(isValidStatus4Opt(status))printRecibo(codigo,compania,anio,'M');}
		else if(option==12){if(!isValidStatus4Opt(status,false)){if(turno==turnoAnula)CBMSG.warning('Solo para Recibos Anulados en turnos diferentes al turno de registro!!');else changeReplaceable(codigo,compania,anio,caja,recibo);}}
		else if(option==14){if(isValidStatus4Opt(status))changeClient(compania,anio,codigo,tipoCliente,recibo,ref_type,sub_ref_id,ref_id, fecha, consecutivo, anio_comprob);}
		else if(option==15){if(isValidStatus4Opt(status))changeTipoClient(compania,anio,codigo,tipoCliente,recibo,ref_type,sub_ref_id,ref_id, fecha, consecutivo, anio_comprob);}
		else if(option==16){if(tipoCliente=='E'){if(isValidStatus4Opt(status))aplicarTxt(codigo,recibo,anio,tipoCliente);}else CBMSG.warning('Solo para recibos de Empresas')}
		}
	}
}
function isValidStatus4Opt(status,showAlert){if(showAlert==undefined||showAlert==null)showAlert=true;if(status=='I'){if(showAlert)CBMSG.warning('Opción no válida para Recibos Anulados!');return false;}return true;}
function distribuir(codigo,compania,anio,tCliente){var tipoCliente ='<%=(fp.trim().equals(""))?tipoCliente:tipoClienteX%>';
if(tipoCliente=='')tipoCliente=tCliente;
abrir_ventana('../caja/reg_recibo.jsp?fg=D&mode=edit&tipoCliente='+tipoCliente+'&codigo='+codigo+'&compania='+compania+'&anio='+anio+'&fp=<%=fp%>');}
function liberar(codigo,compania,anio,recibo,tipoCliente){showPopWin('../common/run_process.jsp?fp=recibos&actType=53&docType=REC&docId='+codigo+'&docNo='+recibo+'&compania='+compania+'&anio='+anio+'&tipoCliente='+tipoCliente,winWidth*.75,winHeight*.65,null,null,'');}
function ajusteAutomatico(codigo,compania,anio,tCliente){var tipoCliente ='<%=(fp.trim().equals(""))?tipoCliente:tipoClienteX%>';if(tipoCliente=='')tipoCliente=tCliente;abrir_ventana('../caja/reg_recibo.jsp?fg=AJ&mode=view&tipoCliente='+tipoCliente+'&codigo='+codigo+'&compania='+compania+'&anio='+anio+'&fp=<%=fp%>');}
function ajusteRecibos(recibo){abrir_ventana('../caja/recibos_ajustes.jsp?codigo='+recibo);}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();chkOther('<%=refer_to%>');}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);showOtros('<%=(fp.trim().equals(""))?tipoCliente:tipoClienteX%>');}
function changeReplaceable(codigo,compania,anio,caja,recibo){showPopWin('../common/run_process.jsp?fp=recibos&actType=59&docType=REC&docId='+codigo+'&docNo='+recibo+'&compania='+compania+'&anio='+anio+'&tipoCliente=<%=(fp.trim().equals(""))?tipoCliente:tipoClienteX%>',winWidth*.75,winHeight*.65,null,null,'');}
function showOtros(tp){
   if(tp==undefined||tp==null)tp='P';
   if(tp!='O'){
	 document.search01.tipoRef.style.display='none';document.search01.tipoRef.value='';
   }
   else {document.search01.tipoRef.style.display='';
   }
}
function setReferTo(obj){var referTo=getSelectedOptionTitle(obj,'');document.search01.refer_to.value=referTo;chkOther(referTo);}
function chkOther(referTo){if(referTo!='CXCO'){document.search01.tipoOtro.style.display='none';document.search01.tipoOtro.value='';	}else{ document.search01.tipoOtro.style.display='';}}
function changeClient(compania,anio,codigo,tipoCliente,recibo,refType,subRefType,refId,fecha, consecutivo, anio_comprob){
	
	 top.CBMSG.alert('Este cambio no se reflejara en la morosidad, para esto debe volver a generar la misma!');showPopWin('../process/cja_upd_client_rec.jsp?compania='+compania+'&anio='+anio+'&codigo='+codigo+'&tipoCliente='+tipoCliente+'&recibo='+recibo+'&refType='+refType+'&subRefType='+subRefType+'&refId='+refId+'&fecha='+fecha+'&consecutivo='+consecutivo+'&anio_comprob='+anio_comprob,winWidth*.75,winHeight*.65,null,null,'');
}
function changeTipoClient(compania,anio,codigo,tipoCliente,recibo,refType,subRefType,refId,fecha, consecutivo, anio_comprob){
	if(tipoCliente=='P' || tipoCliente=='E') {
		if(!chkRecibo(compania,anio,codigo)) alert('El recibo está aplicado!');
	  //else if (!chkMesCerrado()){null;}
		else {
			alert('Este cambio no se reflejara en la morosidad, para esto debe volver a generar la misma!');
			showPopWin('../process/cja_upd_tipo_recibo.jsp?compania='+compania+'&anio='+anio+'&codigo='+codigo+'&tipoCliente='+tipoCliente+'&recibo='+recibo+'&refType='+refType+'&subRefType='+subRefType+'&refId='+refId+'&fecha='+fecha+'&consecutivo='+consecutivo+'&anio_comprob='+anio_comprob,winWidth*.75,winHeight*.65,null,null,'');
		}
	} else alert('Cambio de Tipo de Cliente solo para paciente y empresa!');
}
function chkRecibo(compania,anio,codigo){
	var monto = getDBData('<%=request.getContextPath()%>','nvl((select sum(monto) from tbl_cja_detalle_pago where compania = '+compania+' and codigo_transaccion = '+codigo+' and tran_anio = '+anio+' and (fac_codigo is not null or admi_secuencia is not null)),0)', 'dual');
	if(monto!=0) return false;
	else return true;
}

function chkMesCerrado(){
	var i=parseInt(document.form01.index.value,10);
	var fecha = eval('document.form01.fecha'+i).value;
	var consecutivo = eval('document.form01.consecutivo'+i).value;
	var anio = eval('document.form01.anio_comprob'+i).value;
	var estado = getDBData('<%=request.getContextPath()%>','status', 'tbl_con_encab_comprob', 'ea_ano = '+anio+' and compania = <%=(String) session.getAttribute("_companyId")%> and consecutivo = '+consecutivo)||'';
	if(getDBData('<%=request.getContextPath()%>','estatus', 'tbl_con_estado_meses', 'mes = to_number(to_char(to_date(\''+fecha+'\',\'dd/mm/yyyy\'),\'mm\')) and ano = to_number(to_char(to_date(\''+fecha+'\',\'dd/mm/yyyy\'),\'yyyy\')) and cod_cia = <%=(String) session.getAttribute("_companyId")%>')!='CER' && (estado !='AP' && estado != 'PE')) return true;
	else {alert('El documento seleccionado, esta sobre un mes cerrado o ya fue generado su comprobante!');return false;}
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
	<td align="right">
		<div id="optDesc" class="TextInfo Text10">&nbsp;</div>
		<% if (fp.trim().equals("") || fp.trim().equals("PM")) { %>
		<authtype type='3'><a href="javascript:goOption(0)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,0)" onMouseOut="javascript:mouseOut(this,0)" src="../images/dollar_circle.gif"></a></authtype>
		<% } %>
		<authtype type='1'><a href="javascript:goOption(1)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/search.gif"></a></authtype>
		<% if (fp.trim().equals("")||fp.trim().equals("CSR")) { %>
		<authtype type='2'><a href="javascript:goOption(2)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/printer.gif"></a></authtype>
		<authtype type='58'><a href="javascript:goOption(11)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,11)" onMouseOut="javascript:mouseOut(this,11)" src="../images/printer.gif"></a></authtype>
		<% }%>
		<% if (fp.trim().equals("") || fp.trim().equalsIgnoreCase("ARC")) { %>
		<authtype type='7'><a href="javascript:goOption(3)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/cancel.gif"></a></authtype>
		<authtype type='56'><a href="javascript:goOption(9)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,9)" onMouseOut="javascript:mouseOut(this,9)" src="../images/lock.gif"></a></authtype>
		<authtype type='59'><a href="javascript:goOption(12)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,12)" onMouseOut="javascript:mouseOut(this,12)" src="../images/change_status.png"></a></authtype>
		<% } %>
		<% if (tipoCliente.equalsIgnoreCase("P") || tipoCliente.equalsIgnoreCase("E")||tipoCliente.equalsIgnoreCase("O") || fp.trim().equalsIgnoreCase("ARC")) { %>
		<authtype type='51'><a href="javascript:goOption(4)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,4)" onMouseOut="javascript:mouseOut(this,4)" src="../images/check.gif"></a></authtype>
		<%}
		  if (tipoCliente.equalsIgnoreCase("P") || tipoCliente.equalsIgnoreCase("E") || fp.trim().equalsIgnoreCase("ARC")) { %>
		<authtype type='52'><a href="javascript:goOption(5)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,5)" onMouseOut="javascript:mouseOut(this,5)" src="../images/distribute.gif"></a></authtype>
		<% } %>
		<% if (tipoCliente.equalsIgnoreCase("P") || fp.trim().equalsIgnoreCase("ARC")) { %>
		<authtype type='53'><a href="javascript:goOption(6)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,6)" onMouseOut="javascript:mouseOut(this,6)" src="../images/trash.gif"></a></authtype>
		<% } %>
		<% if (tipoCliente.equalsIgnoreCase("P") || (fp.trim().equalsIgnoreCase("ARC") && tipoClienteX.trim().equals("P"))) { %>
		<authtype type='54'><a href="javascript:goOption(7)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,7)" onMouseOut="javascript:mouseOut(this,7)" src="../images/payment.jpg"></a></authtype>
		<% } %>
		<% if ( tipoCliente.equalsIgnoreCase("P") || (!fp.trim().equals("") && !fp.equalsIgnoreCase("ADMIN")) ) { %>
		<authtype type='55'><a href="javascript:goOption(8)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,8)" onMouseOut="javascript:mouseOut(this,8)" src="../images/flash_auto.gif"></a></authtype>
		<% } %>
		<% if (!fp.equalsIgnoreCase("ADMIN")) { %><authtype type='57'><a href="javascript:goOption(10)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,10)" onMouseOut="javascript:mouseOut(this,10)" src="../images/dollar_circle_adjust.gif"></a></authtype><% } %>
		<% if (fp.trim().equals("")) { %><authtype type='60'><a href="javascript:goOption(13)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,13)" onMouseOut="javascript:mouseOut(this,13)" src="../images/icons/_cashregister48.png"></a></authtype><% } %>
		<% if (fp.equalsIgnoreCase("ADMIN")) { %>
		<authtype type='61'><a href="javascript:goOption(14)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,14)" onMouseOut="javascript:mouseOut(this,14)" src="../images/switch_user.gif"></a></authtype>
		<authtype type='62'><a href="javascript:goOption(15)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,15)" onMouseOut="javascript:mouseOut(this,15)" src="../images/switch_user_plus.png"></a></authtype>
		<% } %>
		<authtype type='63'><a href="javascript:goOption(16)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,16)" onMouseOut="javascript:mouseOut(this,16)" src="../images/proceso.bmp"></a></authtype>
	</td>
</tr>
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<% if (fp.trim().equals("") || fp.equals("PM")) { %>
<%=fb.hidden("tipoCliente",tipoCliente)%>
<% } %>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("refer_to",refer_to)%>
		<tr class="TextFilter" valign="top">
			<%if(fp.equalsIgnoreCase("ARC")){%>
			<td width="23%"><%}else{%><td width="15%"> <%}%>
				Fecha
				<br>
				<%if(fp.equalsIgnoreCase("ARC")){%>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="noOfDateTBox" value="2" />
				<jsp:param name="nameOfTBox1" value="fecha" />
				<jsp:param name="valueOfTBox1" value="<%=fecha%>" />
				<jsp:param name="nameOfTBox2" value="fechaHasta" />
				<jsp:param name="valueOfTBox2" value="<%=fechaHasta%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				</jsp:include>
				<%}else{%>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="fecha" />
				<jsp:param name="valueOfTBox1" value="<%=fecha%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				</jsp:include>
				<%}%>
			</td>
			<td width="8%">
				Recibo
				<br>
				<%=fb.textBox("recibo",recibo,false,false,false,10,"Text10",null,null)%>
			</td>
			<td width="16%">
				Cliente
				<br>
				<%=fb.textBox("nombre",nombre,false,false,false,25,"Text10",null,null)%>
			</td>
			<td width="13%">
				Nombre Adicional
				<br>
				<%=fb.textBox("nombreAdicional",nombreAdicional,false,false,false,25,"Text10",null,null)%>
			</td>
			<td width="30%">
<% if (!fp.equalsIgnoreCase("ADMIN")) { %>
				Caja
				<%sbSql = new StringBuffer();
			if(!UserDet.getUserProfile().contains("0") && fp.trim().equals(""))
			{
				sbSql.append(" and codigo in (");
					if(session.getAttribute("_codCaja")!=null)
						sbSql.append(session.getAttribute("_codCaja"));
					else sbSql.append("-1");
				sbSql.append(")  and estado = 'A' ");
			}%>
				<br>
				<%=fb.select(ConMgr.getConnection(),"select codigo, lpad(codigo,3,'0')||' - '||descripcion from tbl_cja_cajas where compania = "+(String) session.getAttribute("_companyId")+sbSql.toString()+"  order by 2","caja",caja,false,false,0,"Text10",null,null,null,"T")%>
			</td>
			<td width="10%">
				Estado
				<br>
				<%=fb.select("recStatus","A=ACTIVO,I=ANULADO",recStatus,false,false,0,"Text10",null,null,null,"T")%>
<% } %>
<% if (fp.trim().equals("") && !tipoCliente.equalsIgnoreCase("O")) { %>
				<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
			</td>
		</tr>

		<% } else { %> 
			</td>
		</tr>
		<tr class="TextFilter">
			<td colspan="6">

				Tipo Cliente
				<%=fb.select("tipoClienteX",(tipoCliente.equalsIgnoreCase("O"))?"O=OTROS":"P=PACIENTE,E=EMPRESA,O=OTROS",(fp.trim().equals(""))?tipoCliente:tipoClienteX,false,false,0,"Text10",null,"onChange=\"javascript:showOtros(this.value)\"", "", (fp.equalsIgnoreCase("ARC") || fp.equalsIgnoreCase("ADMIN"))?"T":"")%>
				&nbsp;&nbsp;<span id="blkTipoRef"><%=fb.select(ConMgr.getConnection(),"select codigo, codigo||' - '||descripcion, refer_to from tbl_fac_tipo_cliente where compania = "+session.getAttribute("_companyId")+" and activo_inactivo = 'A' order by descripcion","tipoRef",tipoRef,false,false,false,0,"Text10",null,"onChange=\"javascript:setReferTo(this);\"",null,"S")%></span>
				<span id="blkTipoOtro">
				<%=fb.select(ConMgr.getConnection(),"select id, descripcion, id from tbl_cxc_tipo_otro_cliente where compania = "+session.getAttribute("_companyId")+" and estado = 'A' order by descripcion","tipoOtro",tipoOtro,false,false,0,"Text10","","","","T")%></span>
<% if (!tipoCliente.equalsIgnoreCase("O")) { %>
				&nbsp;&nbsp; Codigo Cliente:<%=fb.intBox("codCliente",codCliente,false,false,false,30,"Text10",null,null)%>
<% if (!fp.equalsIgnoreCase("ADMIN")) { %>
				&nbsp;&nbsp;&nbsp;Pendiente por aplicar:<%=fb.checkbox("por_aplicar","S",sPorAplicar.equals("S"),false)%>&nbsp;&nbsp;&nbsp; Usar F. Turno:<%=fb.checkbox("usarFt","S",usarFt.equals("S"),false)%>&nbsp;&nbsp;&nbsp;
				Liberado:<%=fb.checkbox("liberado","S",liberado.equals("S"),false)%>&nbsp;&nbsp;&nbsp; 
<% } %>
				<%if(fp.equalsIgnoreCase("ARC")){%>
				Fecha Anula.
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="noOfDateTBox" value="2" />
				<jsp:param name="nameOfTBox1" value="fAnulaDesde" />
				<jsp:param name="valueOfTBox1" value="<%=fAnulaDesde%>" />
				<jsp:param name="nameOfTBox2" value="fAnulaHasta" />
				<jsp:param name="valueOfTBox2" value="<%=fAnulaHasta%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				</jsp:include>
				<%}%>
<% } %>
				<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
			</td>
		</tr>
<% } %>
<%fb.appendJsValidation("if((document.search01.fecha.value!='' && !isValidateDate(document.search01.fecha.value))){CBMSG.warning('Formato de fecha inválida!');error++;}");%>
<%fb.appendJsValidation("if(document.search01.fechaHasta){if((document.search01.fechaHasta.value!='' && !isValidateDate(document.search01.fechaHasta.value))){CBMSG.warning('Formato de fecha inválida!');error++;}}");%>

<%=fb.formEnd(true)%>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</td>
</tr>
<tr>
	<td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a>
	&nbsp;&nbsp;&nbsp;
	<a href="javascript:printList(1)" class="Link00">[ <cellbytelabel>Imprimir Lista (Excel)</cellbytelabel> ]</a>
	</authtype></td>
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
<%=fb.hidden("tipoCliente",tipoCliente)%>
<%=fb.hidden("tipoClienteX",tipoClienteX)%>
<%=fb.hidden("recibo",recibo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("nombreAdicional",nombreAdicional)%>
<%=fb.hidden("caja",caja)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("recStatus",recStatus)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("codCliente",codCliente)%>
<%=fb.hidden("fechaHasta",fechaHasta)%>
<%=fb.hidden("tipoRef",tipoRef)%>
<%=fb.hidden("por_aplicar",sPorAplicar)%>
<%=fb.hidden("liberado",liberado)%>
<%=fb.hidden("usarFt",usarFt)%>
<%=fb.hidden("fAnulaDesde",fAnulaDesde)%>
<%=fb.hidden("fAnulaHasta",fAnulaHasta)%>
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
<%=fb.hidden("tipoCliente",tipoCliente)%>
<%=fb.hidden("tipoClienteX",tipoClienteX)%>
<%=fb.hidden("recibo",recibo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("nombreAdicional",nombreAdicional)%>
<%=fb.hidden("caja",caja)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("recStatus",recStatus)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("codCliente",codCliente)%>
<%=fb.hidden("fechaHasta",fechaHasta)%>
<%=fb.hidden("tipoRef",tipoRef)%>
<%=fb.hidden("por_aplicar",sPorAplicar)%>
<%=fb.hidden("liberado",liberado)%>
<%=fb.hidden("usarFt",usarFt)%>
<%=fb.hidden("fAnulaDesde",fAnulaDesde)%>
<%=fb.hidden("fAnulaHasta",fAnulaHasta)%>
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
			<td width="11%"><cellbytelabel>Recibo</cellbytelabel></td>
			<td width="21%"><cellbytelabel>Cliente</cellbytelabel></td>
			<td width="21%"><cellbytelabel>Nombre Adicional</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Caja</cellbytelabel></td>
			<td width="7%"><cellbytelabel>Fecha</cellbytelabel></td>
			<td width="7%"><cellbytelabel>Pago Total</cellbytelabel></td>
			<td width="7%"><cellbytelabel>Aplicado</cellbytelabel></td>
			<td width="6%"><cellbytelabel>Ajustes</cellbytelabel></td>
			<td width="6%"><cellbytelabel>Por Aplicar</cellbytelabel></td>
			<td width="6%"><cellbytelabel>Estado</cellbytelabel></td>
			<td width="3%">&nbsp;</td>
		</tr>
<% if (al.size() == 0) { %>
		<tr>
			<td colspan="11" class="TextRow01" align="center"><font color="#FF0000">
				<% if (request.getParameter("recibo") == null) { %>
				<cellbytelabel>I N T R O D U Z C A</cellbytelabel> &nbsp;<cellbytelabel> P A R A M E T R O S</cellbytelabel> &nbsp;<cellbytelabel> P A R A</cellbytelabel> &nbsp;<cellbytelabel> B U S Q U E D A</cellbytelabel>
				<% } else { %>
				<cellbytelabel>N O</cellbytelabel> &nbsp; <cellbytelabel>H A Y</cellbytelabel> &nbsp;<cellbytelabel> R E G I S T R O S</cellbytelabel> &nbsp; <cellbytelabel>E N C O N T R A D O S</cellbytelabel>
				<% } %>
			</font></td>
		</tr>
<% } %>
<%
	double totalPag = 0.0;
	double aplicadoPag = 0.0;
	double ajustadoPag = 0.0;
	double porAplicarPag = 0.0;

for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	double total = Double.parseDouble(cdo.getColValue("pago_total"));
	double aplicado = (cdo.getColValue("aplicado") != null)?Double.parseDouble(cdo.getColValue("aplicado")):0.0;
	double ajustado = (cdo.getColValue("ajustado") != null)?Double.parseDouble(cdo.getColValue("ajustado")):0.0;
	double porAplicar = Math.round((total - aplicado + ajustado) * 100);
	
	  totalPag  += total;
	  aplicadoPag += aplicado;
	  ajustadoPag += ajustado;
	  porAplicarPag += porAplicar;

	
%>
		<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
		<%=fb.hidden("anio"+i,cdo.getColValue("anio"))%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("caja"+i,cdo.getColValue("caja"))%>
		<%=fb.hidden("recibo"+i,cdo.getColValue("recibo"))%>
		<%=fb.hidden("rec_status"+i,cdo.getColValue("rec_status"))%>
		<%=fb.hidden("rec_impreso"+i,cdo.getColValue("rec_impreso"))%>
		<%=fb.hidden("tipo_rec"+i,cdo.getColValue("tipoRec"))%>
		<%=fb.hidden("ref_type"+i,cdo.getColValue("ref_type"))%>
		<%=fb.hidden("ref_id"+i,cdo.getColValue("ref_id"))%>
		<%=fb.hidden("turno"+i,cdo.getColValue("turno"))%>
		<%=fb.hidden("turnoAnula"+i,cdo.getColValue("turno_anulacion"))%>
		<%=fb.hidden("tipoCliente"+i,cdo.getColValue("tipo_cliente"))%>
		<%=fb.hidden("sub_ref_id"+i,cdo.getColValue("sub_ref_id"))%>
		<%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
		<%=fb.hidden("consecutivo"+i,cdo.getColValue("consecutivo"))%>
		<%=fb.hidden("anio_comprob"+i,cdo.getColValue("anio_comprob"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><authtype type='1'><a href="javascript:view(<%=cdo.getColValue("codigo")%>,<%=cdo.getColValue("compania")%>,<%=cdo.getColValue("anio")%>)" class="Link02"><%=(fp.equalsIgnoreCase("ARC"))?cdo.getColValue("tipo_cliente")+"-":""%><%=cdo.getColValue("recibo")%></a></authtype></td>
			<td><%=cdo.getColValue("nombre")%></td>
			<td><%=cdo.getColValue("nombre_adicional")%></td>
			<td align="center"><%=cdo.getColValue("caja")%></td>
			<td align="center"><%=cdo.getColValue("fecha")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("pago_total"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(aplicado)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(ajustado)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(porAplicar / 100)%></td>
			<td align="center"><%=cdo.getColValue("estado")%></td>
			<td align="center"><%=fb.radio("check","",false,false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%></td>
		</tr>
<%
}
%>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
		
<%=fb.formEnd()%>
		</table>
		</div>
		</div>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		  <tr class="TextHeader01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextHeader02')">
			<td width="57%" align="right">T O T A L E S:</td>
			<td width="7%" align="right">&nbsp;</td>
			<td width="7%" align="right"><%=CmnMgr.getFormattedDecimal(totalPag)%></td>
			<td width="7%" align="right"><%=CmnMgr.getFormattedDecimal(aplicadoPag)%></td>
			<td width="6%" align="right"><%=CmnMgr.getFormattedDecimal(ajustadoPag)%></td>
			<td width="6%" align="right"><%=CmnMgr.getFormattedDecimal(porAplicarPag / 100)%></td>
			<td width="6%">&nbsp;</td>
			<td width="4%">&nbsp;</td>
		  </tr>
		</table>
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
<%=fb.hidden("tipoCliente",tipoCliente)%>
<%=fb.hidden("tipoClienteX",tipoClienteX)%>
<%=fb.hidden("recibo",recibo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("nombreAdicional",nombreAdicional)%>
<%=fb.hidden("caja",caja)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("recStatus",recStatus)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("codCliente",codCliente)%>
<%=fb.hidden("fechaHasta",fechaHasta)%>
<%=fb.hidden("tipoRef",tipoRef)%>
<%=fb.hidden("por_aplicar",sPorAplicar)%>
<%=fb.hidden("liberado",liberado)%>
<%=fb.hidden("usarFt",usarFt)%>
<%=fb.hidden("fAnulaDesde",fAnulaDesde)%>
<%=fb.hidden("fAnulaHasta",fAnulaHasta)%>
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
<%=fb.hidden("tipoCliente",tipoCliente)%>
<%=fb.hidden("tipoClienteX",tipoClienteX)%>
<%=fb.hidden("recibo",recibo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("nombreAdicional",nombreAdicional)%>
<%=fb.hidden("caja",caja)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("recStatus",recStatus)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("codCliente",codCliente)%>
<%=fb.hidden("fechaHasta",fechaHasta)%>
<%=fb.hidden("tipoRef",tipoRef)%>
<%=fb.hidden("por_aplicar",sPorAplicar)%>
<%=fb.hidden("liberado",liberado)%>
<%=fb.hidden("usarFt",usarFt)%>
<%=fb.hidden("fAnulaDesde",fAnulaDesde)%>
<%=fb.hidden("fAnulaHasta",fAnulaHasta)%>
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
