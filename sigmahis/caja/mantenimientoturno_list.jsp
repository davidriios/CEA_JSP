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
String fp = request.getParameter("fp");
String caja = request.getParameter("caja");
String codigo = request.getParameter("codigo");
String cajero = request.getParameter("cajero");
String fecha = request.getParameter("fecha");
String cajaEstado = request.getParameter("cajaEstado");
String estadoTurno = request.getParameter("estadoTurno");
String cashier = request.getParameter("cashier");
 
if (fp == null) fp = "";
if (caja == null) caja = "";
if (codigo == null) codigo = "";
if (cajero == null) cajero = "";
if (fecha == null) fecha = "";
if (cajaEstado == null) cajaEstado = "";
if (estadoTurno == null) estadoTurno = "";

//CJA_DEP_CIERRE =Y|N, se usa para que el proceso de deposito sea mandatorio o no.

String cjaDepCierre = "N";

CommonDataObject cdo1 = SQLMgr.getData("select nvl(get_sec_comp_param("+session.getAttribute("_companyId")+",'CJA_DEP_CIERRE'),'N') as cjaDepCierre from dual");
if (cdo1 != null) cjaDepCierre = cdo1.getColValue("cjaDepCierre");

if (request.getMethod().equalsIgnoreCase("GET")) {
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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

	if (!caja.trim().equals("")) { sbFilter.append(" and b.cod_caja = "); sbFilter.append(caja); }
	if (!cajaEstado.trim().equals("")) { sbFilter.append(" and c.estado = '"); sbFilter.append(cajaEstado);sbFilter.append("' "); }
	if (!estadoTurno.trim().equals("")) { sbFilter.append(" and b.estatus = '"); sbFilter.append(estadoTurno);sbFilter.append("' "); }
	if (!codigo.trim().equals("")) { sbFilter.append(" and a.codigo = "); sbFilter.append(codigo); }
	if (!cajero.trim().equals("")) { sbFilter.append(" and exists (select null from tbl_cja_cajera where cod_cajera = a.cja_cajera_cod_cajera and compania = a.compania and upper(nombre) like '%"); sbFilter.append(cajero.toUpperCase()); sbFilter.append("%')"); }
	if (!fecha.trim().equals("")) { sbFilter.append(" and a.fecha = to_date('"); sbFilter.append(fecha); sbFilter.append("','dd/mm/yyyy')"); }

	if (fp.equalsIgnoreCase("transicion") || fp.equalsIgnoreCase("cerrar")) {

		sbFilter.append(" and (( exists (select null from tbl_cja_cajera where cod_cajera = a.cja_cajera_cod_cajera and compania = a.compania and tipo = 'C' and usuario = '");
		sbFilter.append(session.getAttribute("_userName"));
		sbFilter.append("')");
		if (fp.equalsIgnoreCase("transicion")) {

			sbFilter.append(" and b.cod_caja in (");
			if (session.getAttribute("_codCaja") != null) sbFilter.append(session.getAttribute("_codCaja"));
			else sbFilter.append("-1");
			sbFilter.append(")");

		}
		sbFilter.append(" ) or ( exists (select null from tbl_cja_cajas_x_cajero z where compania_caja = b.compania and cod_caja = b.cod_caja");
		if (cashier != null) sbFilter.append(" and cod_cajero = a.cja_cajera_cod_cajera");
		sbFilter.append(" and exists (select null from tbl_cja_cajera where cod_cajera = z.cod_cajero and compania = z.compania_caja and usuario = '");
		sbFilter.append(session.getAttribute("_userName"));
		sbFilter.append("' and tipo in ('S','A'))) ))");

	} else if (fp.equalsIgnoreCase("ver")) {

		sbFilter.append(" and a.hora_final is not null");

	}
	else if (fp.equalsIgnoreCase("temporal")){

		if (!UserDet.getUserProfile().contains("0"))
		{
			sbFilter.append(" and (( exists (select null from tbl_cja_cajera where cod_cajera = a.cja_cajera_cod_cajera and compania = a.compania and tipo = 'C' and usuario = '");
			sbFilter.append(session.getAttribute("_userName"));
			sbFilter.append("')");
			if (fp.equalsIgnoreCase("transicion")) {
	
				sbFilter.append(" and b.cod_caja in (");
				if (session.getAttribute("_codCaja") != null) sbFilter.append(session.getAttribute("_codCaja"));
				else sbFilter.append("-1");
				sbFilter.append(")");
	
			}
			sbFilter.append(" ) or ( exists (select null from tbl_cja_cajas_x_cajero z where compania_caja = b.compania and cod_caja = b.cod_caja and cod_cajero = a.cja_cajera_cod_cajera and exists (select null from tbl_cja_cajera where cod_cajera = z.cod_cajero and compania = z.compania_caja");
			sbFilter.append(" and tipo in ('S','A'))) ))");
		}
		sbFilter.append(" and b.estatus ='T' ");
	} 

	sbSql = new StringBuffer();
	sbSql.append("select a.compania, a.codigo, a.cja_cajera_cod_cajera as cajera, nvl(a.monto_inicial,0) as montoini, to_char(a.hora_inicio,'hh12:mi:ss') as horaini, to_char(a.hora_final,'hh12:mi:ss') as horafin, a.observacion, to_char(a.fecha,'dd/mm/yyyy') as fecha, decode(a.hora_final,null,'N','S') as cerrado, b.cod_caja, b.estatus as estado_turno, decode( b.estatus,'A','ACTIVO','I','CERRADO','T','TRAMITE') as estadoTurno");
	sbSql.append(", nvl((select 'S' from tbl_cja_sesdetails where session_id = a.codigo and company_id = a.compania),'N') as mostrar");
	sbSql.append(", c.descripcion  as caja_nombre");
	sbSql.append(", decode(c.estado,'A','ACTIVO','I','INACTIVO') as caja_estado");
	sbSql.append(", nvl(ip,' ') as ip");
	sbSql.append(", nvl((select nombre from tbl_cja_cajera where cod_cajera = a.cja_cajera_cod_cajera and compania = a.compania),' ') as cajeraname");

	sbSql.append(" from tbl_cja_turnos a, tbl_cja_turnos_x_cajas b,tbl_cja_cajas c where a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and a.compania = b.compania and a.codigo = b.cod_turno");
	sbSql.append(" and c.compania = b.compania and c.codigo = b.cod_caja");
	sbSql.append(sbFilter);
	sbSql.append(" order by a.codigo desc");

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql+")");

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
document.title = 'Mantenimiento de Turno - '+document.title;

function add(){ abrir_ventana('../caja/mantenimientoturno_config.jsp');}
function edit(id){abrir_ventana('../caja/mantenimientoturno_config.jsp?mode=edit&id='+id);}
function view(id){abrir_ventana('../caja/mantenimientoturno_config.jsp?mode=view&id='+id);}
function verCierre(id){abrir_ventana('../caja/ver_cierre_caja.jsp?id='+id);}
function cerrar(turno){
	var cjaDepCierre = "<%=cjaDepCierre%>";  
	var count=parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_cja_turnos_x_cajas','compania=<%=(String) session.getAttribute("_companyId")%> and cod_turno='+turno+' and estatus in (\'A\', \'T\')'),10);
	var depositos = parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_con_movim_bancario','compania=<%=(String) session.getAttribute("_companyId")%> and (turno='+turno+' or  fn_cja_check_mb (turnos_cierre , '+turno+' ) > 0 )'),10);
	var continuar='';
	var msg = "Estimado USUARIO: No se ha encontrado registros de depósitos de su turno,\n- Esto afectará otros procesos Contables!!";
	if (depositos=='0'){
	   if (cjaDepCierre == "Y") {CBMSG.warning(msg+" No puede continuar con el cierre de caja.");continuar="";}
	   else if(confirm(msg+"\n- Desea Continuar!!!")){continuar='S';}
	}

	if (depositos!='0'||continuar=='S'){
	if(count==1) abrir_ventana('../caja/cierre_caja.jsp?id='+turno+'&sinDepositos='+continuar);
	else if(count>1)CBMSG.warning('Se ha detectado más de un turno activo en esta caja...');
	else CBMSG.warning('La caja no existe o ya está cerrada. Por favor verifique!');
	window.location.reload(true);}else if(continuar!='S'){ return;}
}

function tramite(cod_turno, cod_caja){
	var reemplazo=getDBData('<%=request.getContextPath()%>',' ( select sum(nvl(valor,0))  as saldo  from    (select sum(pago_total*-1)  valor  from tbl_cja_transaccion_pago where compania=<%=(String) session.getAttribute("_companyId")%>  and turno_anulacion = '+cod_turno+'  and rec_status= \'I\'   and turno <> turno_anulacion  and nvl(anulacion_sup,\'x\') <> \'S\' union select sum(pago_total)  from tbl_cja_transaccion_pago a   where a.compania=<%=(String) session.getAttribute("_companyId")%>  and a.turno  = '+cod_turno+'   and a.rec_status  = \'A\'   and exists  (select 1  from tbl_cja_trans_forma_pagos b  where b.compania = a.compania   and b.tran_anio  = a.anio  and b.tran_codigo  = a.codigo   and b.fp_codigo = 0) ) ) valor ',' dual ','');
	var count=parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_cja_turnos_x_cajas','compania=<%=(String) session.getAttribute("_companyId")%> and cod_caja='+cod_caja+' and estatus = \'T\' '),10);
	var clientIdentifier = '<%=ConMgr.getClientIdentifier()%>';
	var depositos = 0;//parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_con_movim_bancario','compania=<%=(String) session.getAttribute("_companyId")%> and turno='+cod_turno+' '),10);
	if (reemplazo=='0')
	{
			if (count<=2)
				{
					//if (depositos!='0')
					//{
							if(confirm('Confirma que desea poner en tramite la caja '+cod_caja+', turno '+cod_turno+'?'))
							{

								showPopWin('../common/run_process.jsp?fp=CJA&actType=50&docType=CJA&docId='+cod_turno+'&docNo='+cod_caja+'&compania=<%=(String) session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.20,null,null,'')

								/*if(executeDB('<%=request.getContextPath()%>','call sp_cja_tramite_caja(<%=(String) session.getAttribute("_companyId")%>, '+cod_caja+', '+cod_turno+', \'<%=(String) session.getAttribute("_userName")%>\')'))
								{
									var msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);
									CBMSG.warning(msg);
									window.location.reload(true);
								} else {
									var msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);
									CBMSG.warning(msg);
								}*/
							}
					//} else CBMSG.warning('Estimado USUARIO: RECUERDE registrar los depósitos antes de poner en TRAMITE su turno. . . GRACIAS!');
				} else  CBMSG.warning('Existe mas de (2) turno en estado TRAMITE. Solo está permitido tener dos turno en TRAMITE por caja!');
	} else CBMSG.warning('Existen recibos ANULADOS que no han sido REEMPLAZADOS, debe completar este paso para poder poner en TRAMITE este turno!');


}
function printList(){abrir_ventana('../caja/print_list_turnos.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>');}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function activarTurno(turno,caja){
var tActivos=getDBData('<%=request.getContextPath()%>','count(*)','tbl_cja_turnos_x_cajas','compania = <%=(String) session.getAttribute("_companyId")%> and cod_caja = '+caja+' and estatus = \'A\'');
if(tActivos ==0){
if(confirm('Confirma que desea ACTIVAR el turno: '+turno+' de la caja NO.: '+caja+'?')){showPopWin('../common/run_process.jsp?fp=CJA&actType=52&docType=CJA&docId='+turno+'&docNo='+caja+'&compania=<%=(String) session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.20,null,null,'');
}
}else CBMSG.warning('No se puede Activar el Turno: '+turno+' de la Caja ='+caja+'. Ya existe otro Turno Activo');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CAJA - MANTENIMIENTO DE TURNO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right"><% if (!fp.equalsIgnoreCase("transicion") && !fp.equals("cerrar") && !fp.equals("ver")) { %><authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel>Registrar Turno</cellbytelabel> ]</a></authtype><% } %></td>
</tr>
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=(cashier == null)?"":fb.hidden("cashier","")%>
			<td>
				<cellbytelabel>Caja</cellbytelabel>
<%
sbSql = new StringBuffer();
sbSql.append("select codigo, descripcion from tbl_cja_cajas a where compania = ");
sbSql.append(session.getAttribute("_companyId"));
if (fp.equalsIgnoreCase("transicion") || fp.equalsIgnoreCase("cerrar")||(fp.equalsIgnoreCase("temporal") && !UserDet.getUserProfile().contains("0"))) {

	sbSql.append(" and exists (select null from tbl_cja_turnos_x_cajas z where z.compania = a.compania and z.cod_caja = a.codigo and (( exists (select null from tbl_cja_turnos y where y.compania = z.compania and y.codigo = z.cod_turno and exists (select null from tbl_cja_cajera where cod_cajera = y.cja_cajera_cod_cajera and compania = y.compania and tipo = 'C' and usuario = '");
	sbSql.append(session.getAttribute("_userName"));
	sbSql.append("'))");
	if (fp.equalsIgnoreCase("transicion")||(fp.equalsIgnoreCase("temporal") && !UserDet.getUserProfile().contains("0"))) {

		sbSql.append(" and z.cod_caja in (");
		if (session.getAttribute("_codCaja") != null) sbSql.append(session.getAttribute("_codCaja"));
		else sbSql.append("-1");
		sbSql.append(")");

	}
	sbSql.append(" ) or ( exists (select null from tbl_cja_cajas_x_cajero y where y.compania_caja = z.compania and y.cod_caja = z.cod_caja and exists (select null from tbl_cja_cajera where cod_cajera = y.cod_cajero and compania = y.compania_caja and usuario = '");
	sbSql.append(session.getAttribute("_userName"));
	sbSql.append("' and tipo in ('S','A'))) )))");

}
sbSql.append(" order by descripcion");
%>
				<%=fb.select(ConMgr.getConnection(),sbSql.toString(),"caja",caja,false,false,0,"Text10",null,null,null,(fp.equalsIgnoreCase("ver") ||(!fp.equalsIgnoreCase("transicion") && !fp.equalsIgnoreCase("cerrar")))?"T":"")%>
				<%//=fb.select(ConMgr.getConnection(),"select c.codigo, c.codigo ||' - ' ||c.descripcion descripcion from tbl_cja_cajas c where c.compania = "+session.getAttribute("_companyId")+" and c.codigo in (select cod_caja from tbl_cja_cajas_x_cajero where cod_cajero = (select cod_cajera from tbl_cja_cajera where compania = "+session.getAttribute("_companyId")+" and usuario = '"+(String) session.getAttribute("_userName")+"' and tipo in ('S', 'A')) and compania_caja = c.compania) order by c.descripcion asc","caja",caja,false,false,0,null,null,"")%>
				<cellbytelabel>Turno</cellbytelabel>
				<%=fb.textBox("codigo",codigo,false,false,false,15)%>
				<cellbytelabel>Cajero</cellbytelabel>
				<%=fb.textBox("cajero",cajero,false,false,false,30)%>
				<cellbytelabel>Fecha</cellbytelabel>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="clearOption" value="true"/>
				<jsp:param name="nameOfTBox1" value="fecha"/>
				<jsp:param name="valueOfTBox1" value="<%=fecha%>"/>
				</jsp:include>
				
				Estado Caja: <%=fb.select("cajaEstado","A=ACTIVO,I=INACTIVO",cajaEstado,false,false,0,"Text10","","","","T")%>
				<%if(!fp.equalsIgnoreCase("temporal")){%>Estado Turno:  <%=fb.select("estadoTurno","A=ACTIVO,I=CERRADO,T=TRAMITE",estadoTurno,false,false,0,"Text10","","","","T")%><%}%>
				<%=fb.submit("go","Ir")%>
			</td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td align="right"><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></td>
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
<%=fb.hidden("fp",fp)%>
<%=(cashier == null)?"":fb.hidden("cashier","")%>
<%=fb.hidden("caja",caja)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("cajero",cajero)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("cajaEstado",cajaEstado)%>
<%=fb.hidden("estadoTurno",estadoTurno)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s</cellbytelabel>) <%=rowCount%></td>
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
<%=fb.hidden("fp",fp)%>
<%=(cashier == null)?"":fb.hidden("cashier","")%>
<%=fb.hidden("caja",caja)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("cajero",cajero)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("cajaEstado",cajaEstado)%>
<%=fb.hidden("estadoTurno",estadoTurno)%>
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
		<tr class="TextHeader">
			<td width="5%" align="center"><cellbytelabel>Turno</cellbytelabel></td>
			<td width="25%" align="center"><cellbytelabel>Cajero</cellbytelabel></td>
			<td width="9%" align="center"><cellbytelabel>Fecha</cellbytelabel></td>
			<td width="19%" align="center"><cellbytelabel>Caja</cellbytelabel></td>
			<td width="10%" align="center"><cellbytelabel>Estado Caja</cellbytelabel></td>
			<td width="10%" align="center"><cellbytelabel>IP</cellbytelabel></td>
			<td width="7%" align="center"><cellbytelabel>Estado</cellbytelabel></td>
			<td width="5%">&nbsp;</td>
			<td width="10%">&nbsp;</td>
		</tr>
<%
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("cajeraName")%></td>
			<td><%=cdo.getColValue("fecha")%></td>
			<td><%=cdo.getColValue("cod_caja")%>-<%=cdo.getColValue("caja_nombre")%></td>
			<td><%=cdo.getColValue("caja_estado")%></td>
			<td><%=cdo.getColValue("ip")%></td>
			<td><%=cdo.getColValue("estadoTurno")%></td>
			<td align="center">&nbsp;<authtype type='1'><a href="javascript:view(<%=cdo.getColValue("codigo")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Ver</cellbytelabel></a></authtype></td>
			<td align="center">
				<% if ((fp.equalsIgnoreCase("transicion") || fp.equalsIgnoreCase("cerrar") || fp.equalsIgnoreCase("ver")) && cdo.getColValue("cerrado").equalsIgnoreCase("S") && cdo.getColValue("mostrar").equalsIgnoreCase("S")) { %>
				<authtype type='1'><a href="javascript:verCierre(<%=cdo.getColValue("codigo")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Ver Cierre</cellbytelabel></a></authtype>
				<% } else if ((fp.equalsIgnoreCase("transicion") || fp.equalsIgnoreCase("cerrar")) && cdo.getColValue("cerrado").equalsIgnoreCase("N")) { %>
				<authtype type='50'><% if (cdo.getColValue("estado_turno").equalsIgnoreCase("T")) { %><a href="javascript:cerrar(<%=cdo.getColValue("codigo")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Cerrar</cellbytelabel></a><% } else if (fp.equalsIgnoreCase("transicion") && cdo.getColValue("estado_turno").equalsIgnoreCase("A")) { %><a href="javascript:tramite(<%=cdo.getColValue("codigo")%>,<%=cdo.getColValue("cod_caja")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Transici&oacute;n</cellbytelabel></a><% } %></authtype>
				<% } %>
				<%if(fp.equalsIgnoreCase("temporal")){%>
				<authtype type='52'><a href="javascript:activarTurno(<%=cdo.getColValue("codigo")%>,<%=cdo.getColValue("cod_caja")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Activar</cellbytelabel></a></authtype>
				<%}%>
				
			</td>
		</tr>
<% } %>
		</table>
</div>
</div>
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
<%=fb.hidden("fp",fp)%>
<%=(cashier == null)?"":fb.hidden("cashier","")%>
<%=fb.hidden("caja",caja)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("cajero",cajero)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("cajaEstado",cajaEstado)%>
<%=fb.hidden("estadoTurno",estadoTurno)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%> <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
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
<%=(cashier == null)?"":fb.hidden("cashier","")%>
<%=fb.hidden("caja",caja)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("cajero",cajero)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("cajaEstado",cajaEstado)%>
<%=fb.hidden("estadoTurno",estadoTurno)%>
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
<% } %>
