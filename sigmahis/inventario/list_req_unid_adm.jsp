<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%
/**
==========================================================================================
tr	= 	Tipo de requisicion
===================================================================================
UA	= 	REQUISICION DE MATERIALES Y EQUIPOS DE UNIDADES ADMINISTRATIVAS
UAT = 	REQUISICION DE MATERIALES Y EQUIPOS DE UNIDADES ADMINISTRATIVAS TEMPORALES
SM	=		REQUISICION DE MATERIALES PARA SERVICIOS DE MANTENIMIENTO
EC	=		REQUISICION DE MATERIALES ENTRE COMPAÑIAS
EA	=		REQUISICION DE MATERIALES ENTRE ALMACENES
US	=		REQUISICION DE MATERIALES PARA USOS DE SALAS
//tipo_unidad_adm=2 == unidades de usos de salas (centros de servicios)
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alWh = new ArrayList();

int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbCol = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String tipo_solicitud = request.getParameter("tipo_solicitud");
String estado = request.getParameter("estado");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String wh = request.getParameter("wh");
String tipo = request.getParameter("tipo");
String tr = request.getParameter("tr");
String trTitle = "";
String anio = request.getParameter("anio");
String cod_req = request.getParameter("cod_req");
String solicitado_por = request.getParameter("solicitado_por");
String sol_a = request.getParameter("sol_a");

if (tipo_solicitud == null) tipo_solicitud = "";
if (estado == null) estado = "";
if (fechaini == null ) fechaini = "";
if (fechafin == null ) fechafin = "";
if (tipo == null ) tipo = "UA";

if (anio == null) anio = "";
if (cod_req == null) cod_req = "";
if (solicitado_por == null) solicitado_por = "";
if (sol_a == null) sol_a = "";

if (tr == null || tr.trim().equals("")) throw new Exception("El Tipo de Requisición no es válido. Por favor intente nuevamente!");

sbSql.append("select codigo_almacen as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania = ");
sbSql.append(session.getAttribute("_companyId"));
if (!UserDet.getUserProfile().contains("0")) {
	if (session.getAttribute("_almacen_ua") != null) {
	sbSql.append(" and codigo_almacen in (");
	sbSql.append(CmnMgr.vector2numSqlInClause((Vector)session.getAttribute("_almacen_ua")));
	sbSql.append(")");}
	else sbSql.append(" and codigo_almacen in (-2)");
}
sbSql.append(" order by codigo_almacen");
alWh = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CommonDataObject.class);

if (wh == null) {
	if (SecMgr.getParValue(UserDet,"almacen_ua") != null && !SecMgr.getParValue(UserDet,"almacen_ua").equals("")) wh = SecMgr.getParValue(UserDet,"almacen_ua");
	else wh = "";
}
if (!wh.trim().equals("")) {
	sbFilter.append(" and (a.codigo_almacen = ");
	sbFilter.append(wh);
	sbFilter.append(" or a.codigo_almacen_ent = ");
	sbFilter.append(wh);
	sbFilter.append(")");
} else {
	if (tr.equalsIgnoreCase("EA")) {
		if (!UserDet.getUserProfile().contains("0")) {
			if (session.getAttribute("_almacen_ua") != null) {
				sbFilter.append(" and (codigo_almacen in (");
				sbFilter.append(CmnMgr.vector2numSqlInClause((Vector)session.getAttribute("_almacen_ua")));
				sbFilter.append(") or a.codigo_almacen_ent in (");
				sbFilter.append(CmnMgr.vector2numSqlInClause((Vector)session.getAttribute("_almacen_ua")));
				sbFilter.append("))");
			} else sbFilter.append(" and codigo_almacen in (-2)");
		}
	}
}

if (!tipo_solicitud.trim().equals("")) { sbFilter.append(" and upper(a.tipo_solicitud) = '"); sbFilter.append(tipo_solicitud.toUpperCase()); sbFilter.append("'"); }

if (tr.equalsIgnoreCase("RS")) {//Rechazar solicitud

	sbCol.append(", to_char(a.fecha_creacion,'mm') as mes, nvl(to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi am'),' ') as fecha_docto, decode(a.activa,'S',decode(a.estado_solicitud,'A','S','N'),'N') as entregar");

	trTitle = "INVENTARIO - RECHAZAR REQ. MATERIALES Y EQUIPOS DE UNIDADES ADMIN. TRANSF";
	if (tipo.equalsIgnoreCase("EA")) sbFilter.append(" and a.tipo_transferencia = 'A'");//Rechazar solicitud de almacenes
	else if (tipo.equalsIgnoreCase("UA")) sbFilter.append(" and a.tipo_transferencia = 'U'");//Rechazar solicitud de unidades
	if (estado.trim().equals("")) sbFilter.append(" and a.estado_solicitud in ('A','P','N','T','E')");
	else { sbFilter.append(" and a.estado_solicitud = '"); sbFilter.append(estado); sbFilter.append("'"); }

	sbFilter.append(" and exists (select null from tbl_inv_d_sol_req where req_anio = a.anio and tipo_solicitud = a.tipo_solicitud and solicitud_no = a.solicitud_no and compania = a.compania and estado_renglon = 'P')");

} else {

	sbCol.append(", to_char(a.fecha_documento,'mm') as mes, nvl(to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi am'),' ') as fecha_docto, ");
	if (!UserDet.getUserProfile().contains("0") && tr.equalsIgnoreCase("EA")) {
		sbCol.append(" case when a.activa = 'S' and a.estado_solicitud = 'A' and a.codigo_almacen_ent in (");
		if (session.getAttribute("_almacen_ua") != null) sbCol.append(CmnMgr.vector2numSqlInClause((Vector)session.getAttribute("_almacen_ua")));
		else sbCol.append("-2");
		sbCol.append(") then 'S' else 'N' end");
	} else sbCol.append(" decode(a.activa,'S',decode(a.estado_solicitud,'A','S','N'),'N')");
	sbCol.append(" as entregar");

	if (tr.equalsIgnoreCase("UA")) {
		trTitle = "INVENTARIO - REQ. MATERIALES Y EQUIPOS DE UNIDADES ADMIN.";
		sbFilter.append(" and a.tipo_transferencia = 'U' and a.codigo_centro is null");
		//sbFilter.append(" and not exists (select null from tbl_sec_unidad_ejec where compania = a.compania and codigo = a.unidad_administrativa and tipo_unidad_adm = 2)");
	} else if (tr.equalsIgnoreCase("UAT")) {
		trTitle = "INVENTARIO - REQ. MATERIALES Y EQUIPOS DE UNIDADES ADMIN. - TEMPORAL";
	} else if (tr.equalsIgnoreCase("SM")) {
		trTitle = "INVENTARIO - REQ. MATERIALES PARA SERVICIOS DE MANTENIMIENTO";
	} else if (tr.equalsIgnoreCase("EC")) {
		trTitle = "INVENTARIO - REQUISICION DE MATERIALES ENTRE COMPA&Ntilde;IAS";
		sbFilter.append(" and a.tipo_transferencia = 'C'");
	} else if (tr.equalsIgnoreCase("EA")) {
		trTitle = "INVENTARIO - REQUISICION DE MATERIALES ENTRE ALMACENES";
		sbFilter.append(" and a.tipo_transferencia = 'A'");
	} else if (tr.equalsIgnoreCase("US")) {
		trTitle = "INVENTARIO - REQUISICION DE MATERIALES PARA USOS DE SALAS";
		sbFilter.append(" and a.tipo_transferencia = 'U'");
		sbFilter.append(" and exists (select null from tbl_sec_unidad_ejec where compania = a.compania and codigo = a.unidad_administrativa and tipo_unidad_adm = 2)");
	}
	if (!estado.trim().equals("") && !estado.trim().equals("A") && !estado.trim().equals("E")) { sbFilter.append(" and upper(a.estado_solicitud) = '"); sbFilter.append(estado.toUpperCase()); sbFilter.append("'"); }
	else if (estado.trim().equals("E")) sbFilter.append(" and a.estado_solicitud = 'A' and activa = 'N'");
	else if (estado.trim().equals("A")) sbFilter.append(" and a.estado_solicitud = 'A' and activa = 'S'");
	

}

if (tr.equalsIgnoreCase("UA") || tr.equalsIgnoreCase("EC") || tr.equalsIgnoreCase("US")) {
	if (!UserDet.getUserProfile().contains("0")) {
		sbFilter.append(" and a.unidad_administrativa in (");
		if (session.getAttribute("_ua") != null) sbFilter.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_ua")));
		else sbFilter.append("-1");
		sbFilter.append(")");

		if (tr.equalsIgnoreCase("UA") || tr.equalsIgnoreCase("US")) {
			sbFilter.append(" and a.codigo_almacen in (");
			if (session.getAttribute("_almacen_ua") != null) sbFilter.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_almacen_ua")));
			else sbFilter.append("-2");
			sbFilter.append(")");
		}
	}
}

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

	if (!cod_req.trim().equals("")) { sbFilter.append(" and a.solicitud_no = "); sbFilter.append(cod_req); }
	if (!anio.trim().equals("")) { sbFilter.append(" and a.anio = "); sbFilter.append(anio); }
	if (!sol_a.trim().equals("")) {
		//if (tr.equalsIgnoreCase("EA")) { sbFilter.append(" and upper(a.solicitado_por) like '%"); sbFilter.append(sol_a); sbFilter.append("%'"); }
		//else { sbFilter.append(" and upper(a.solicitado_a) like '%"); sbFilter.append(sol_a); sbFilter.append("%'"); }

		if (tr.equalsIgnoreCase("EA")) {
			sbFilter.append(" and exists (select null from tbl_inv_almacen where compania = a.compania and codigo_almacen = a.codigo_almacen_ent and codigo_almacen||' '||descripcion like '%"); sbFilter.append(sol_a.toUpperCase()); sbFilter.append("%')");
		} else if (tr.equalsIgnoreCase("EC") || tipo.equalsIgnoreCase("EC")) {
			sbFilter.append(" and exists (select null from tbl_sec_compania where codigo = a.compania_sol and codigo||' '||nombre like '%"); sbFilter.append(sol_a.toUpperCase()); sbFilter.append("%')");
		} else {
			sbFilter.append(" and exists (select null from tbl_inv_almacen where compania = a.compania and codigo_almacen = a.codigo_almacen and codigo_almacen||' '||descripcion like '%"); sbFilter.append(sol_a.toUpperCase()); sbFilter.append("%')");
		}
	}
	if (!solicitado_por.trim().equals("")) {
		//if (tr.equals("EA")) { sbFilter.append(" and upper(a.solicitado_a) like '%"); sbFilter.append(solicitado_por); sbFilter.append("%'"); }
		//else { sbFilter.append(" and upper(a.solicitado_por) like '%"); sbFilter.append(solicitado_por); sbFilter.append("%'"); }

		if (tr.equalsIgnoreCase("EA")) {
			sbFilter.append(" and exists (select null from tbl_inv_almacen where compania = a.compania and codigo_almacen = a.codigo_almacen and codigo_almacen||' '||descripcion like '%"); sbFilter.append(solicitado_por.toUpperCase()); sbFilter.append("%')");
		} else if (tr.equalsIgnoreCase("US") || tipo.equalsIgnoreCase("US")) {
			sbFilter.append(" and exists (select null from tbl_cds_centro_servicio where codigo = a.codigo_centro and compania_unorg = a.compania and codigo||' '||descripcion like '%"); sbFilter.append(solicitado_por.toUpperCase()); sbFilter.append("%')");
		} else {
			sbFilter.append(" and exists (select null from tbl_sec_unidad_ejec where compania = a.compania and codigo = a.unidad_administrativa and codigo||' '||descripcion like '%"); sbFilter.append(solicitado_por.toUpperCase()); sbFilter.append("%')");
		}
	}
	if (!fechaini.trim().equals("")) { if (tr.equalsIgnoreCase("RS")) sbFilter.append(" and trunc(a.fecha_documento) >= to_date('"); else sbFilter.append(" and trunc(a.fecha_creacion) >= to_date('"); sbFilter.append(fechaini); sbFilter.append("','dd/mm/yyyy')"); }
	if (!fechafin.trim().equals("")) { if (tr.equalsIgnoreCase("RS")) sbFilter.append(" and trunc(a.fecha_documento) <= to_date('"); else sbFilter.append(" and trunc(a.fecha_creacion) <= to_date('"); sbFilter.append(fechafin); sbFilter.append("','dd/mm/yyyy')"); }

	if (request.getParameter("fechaini") != null) {

		sbSql = new StringBuffer();
		sbSql.append("select a.fecha_creacion as fecha, a.compania, a.anio, a.solicitud_no, a.tipo_solicitud, decode(a.tipo_solicitud,'D','DIARIA','S','SEMANAL','Q','QUINCENAL','M','MENSUAL') as desc_tipo_solicitud, a.estado_solicitud, DECODE(a.estado_solicitud,'A',decode(activa, 'S', 'APROBADO', 'ENTREGADO'),'P','PENDIENTE','R','RECHAZADO','N','ANULADO','T','TRAMITE','E','ENTREGADO') as desc_estado, nvl(a.activa,'N') as activa, a.compania_sol, a.codigo_almacen, a.fecha_creacion, nvl(decode(a.usuario_aprob,'null',' ',a.usuario_aprob),' ') as usuarioAprob, a.codigo_almacen_ent, decode('");
		if (tr.equalsIgnoreCase("RS")) sbSql.append(tipo);
		else sbSql.append(tr);
		sbSql.append("','UA',(select codigo||' '||descripcion from tbl_sec_unidad_ejec where compania = a.compania and codigo = a.unidad_administrativa),'SM',(select codigo||' '||descripcion from tbl_sec_unidad_ejec where compania = a.compania and codigo = a.unidad_administrativa),'EC',(select codigo||' '||descripcion from tbl_sec_unidad_ejec where compania = a.compania and codigo = a.unidad_administrativa),'EA',(select codigo_almacen||' '||descripcion from tbl_inv_almacen where compania = a.compania and codigo_almacen = a.codigo_almacen_ent),'US',(select codigo||' '||descripcion from tbl_cds_centro_servicio where codigo = a.codigo_centro and compania_unorg = a.compania),' ') as solicitado_por, decode('");
		if (tr.equalsIgnoreCase("RS")) sbSql.append(tipo);
		else sbSql.append(tr);
		sbSql.append("','UA',(select codigo_almacen||' '||descripcion from tbl_inv_almacen where compania = a.compania and codigo_almacen = a.codigo_almacen),'SM',(select codigo_almacen||' '||descripcion from tbl_inv_almacen where compania = a.compania and codigo_almacen = a.codigo_almacen),'EC',(select codigo||' '||nombre from tbl_sec_compania where codigo = a.compania_sol),'EA',(select codigo_almacen||' '||descripcion from tbl_inv_almacen where compania = a.compania and codigo_almacen = a.codigo_almacen),'US',(select codigo_almacen||' '||descripcion from tbl_inv_almacen where compania = a.compania and codigo_almacen = a.codigo_almacen),' ') as solicitado_a");
		sbSql.append(sbCol);
		sbSql.append(", (select name from tbl_sec_users where user_name = a.usuario_creacion and rownum = 1 ) as usuario_creacion,to_char(a.fecha_modificacion,'dd/mm/yyyy') as fecha_aprob ");
		sbSql.append(" from tbl_inv_solicitud_req a where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(sbFilter);
		sbSql.append(" order by 1 desc, 4 desc");

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
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Inventario - '+document.title;
function add(){abrir_ventana('../inventario/reg_req_unid_adm.jsp?tr=<%=tr%>');}
function ver(anio, id, tp){	var tr = '<%=tr%>';<% if (tr.equalsIgnoreCase("RS")) { %>var tipo = document.search00.tipo.value;tr = tipo+'&fg=RS';<% } %>abrir_ventana('../inventario/reg_req_unid_adm.jsp?mode=view&id='+id+'&anio='+anio+'&tipoSolicitud='+tp+'&tr='+tr);}
function edit(anio, id, tp){abrir_ventana('../inventario/reg_req_unid_adm.jsp?mode=edit&id='+id+'&anio='+anio+'&tipoSolicitud='+tp+'&tr=<%=tr%>');}
function approve(anio,mes, id, tp,wh){abrir_ventana('../inventario/aprove_requisicion.jsp?mode=approve&id='+id+'&anio='+anio+'&mes='+mes+'&tipoSolicitud='+tp+'&tr=<%=tr%>&almacen='+wh);}
function printList(){<% if (request.getParameter("fechaini") == null) { %>alert('Por favor realice una búsqueda antes de continuar!');<% } else { %>abrir_ventana('../inventario/print_list_req_unid_adm.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>&tr=<%=tr%>&tipo=<%=tipo%>');<% } %>}
function entregar(anio, ts, sol_no, cia){abrir_ventana('../inventario/reg_delivery.jsp?anio='+anio+'&tipo_solicitud='+ts+'&solicitud_no='+sol_no+'&compania='+cia+'&fp=requisitions&fg=<%=tr%>');}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function showReq(anio,id,tipo){<% if (tr.equalsIgnoreCase("UA")) { %>abrir_ventana1('../inventario/print_sol_req_unidad_adm.jsp?fp=UA&anio='+anio+'&cod_req='+id+'&tipo='+tipo);<% } else if (tr.equalsIgnoreCase("EA")) { %>abrir_ventana1('../inventario/print_sol_req_almacenes.jsp?print_individual=S&fg=REA&fp=EA&anio='+anio+'&cod_req='+id+'&tipo='+tipo);<% } else { %>alert('La impresión (<%=tr%>) no está definida!');<% } %>}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="<%=trTitle%>"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right">&nbsp;<% if (!tr.equalsIgnoreCase("RS")) { %><authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nueva Requisici&oacute;n ]</a></authtype><% } %></td>
</tr>
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("tr",tr)%>
		<tr class="TextFilter">
			<td width="30%">Almac&eacute;n<%=fb.select("wh",alWh,wh,"T")%></td>
			<td width="70%">
			<%String  t_s="";
			if(tr.trim().equals("UA"))t_s="S=SEMANAL,D=DIARIA";
			else if(tr.trim().equals("EA"))t_s="D=DIARIA";
			else t_s="D=DIARIA,S=SEMANAL,Q=QUINCENAL,M=MENSUAL";
			%>
			Tipo Solicitud<%=fb.select("tipo_solicitud",""+t_s,tipo_solicitud,false,false,0,"T")%>
				Estado<%=fb.select("estado","T=TRAMITE,A=APROBADO,P=PENDIENTE,R=RECHAZADO,N=ANULADO,E=ENTREGADO",estado,false,false,0,"T")%>
				<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="2"/>
					<jsp:param name="clearOption" value="true"/>
					<jsp:param name="nameOfTBox1" value="fechaini"/>
					<jsp:param name="valueOfTBox1" value="<%=fechaini%>"/>
					<jsp:param name="nameOfTBox2" value="fechafin"/>
					<jsp:param name="valueOfTBox2" value="<%=fechafin%>"/>
				</jsp:include>
			</td>
		</tr>
		<tr class="TextFilter">
			<td>
				A&ntilde;o<%=fb.intBox("anio","",false,false,false,5)%>
				No Requisici&oacute;n <%=fb.intBox("cod_req","",false,false,false,10)%>
			</td>
			<td>
				Solicitado por<%=fb.textBox("solicitado_por","",false,false,false,30)%>
				Solicitado A<%=fb.textBox("sol_a","",false,false,false,30)%>
				<% if (tr.equalsIgnoreCase("RS")) { %>
				Tipo Mov<%=fb.select("tipo","UA=UNIDAD ADMIN,EA=TRANSF ALM",tipo,false,false,0,"")%>
				<% } %>
				<%=fb.submit("go","Ir")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</td>
</tr>
<tr>
	<td align="right">&nbsp;<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
</tr>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp","","onSubmit=\"javascript:return(replacePercent(this.searchVal))\"");%>
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
<%=fb.hidden("tr",tr)%>
<%=fb.hidden("wh",wh)%>
<%=fb.hidden("tipo_solicitud",tipo_solicitud)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("fechaini",fechaini)%>
<%=fb.hidden("fechafin",fechafin)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("cod_req",cod_req)%>
<%=fb.hidden("solicitado_por",solicitado_por)%>
<%=fb.hidden("sol_a",sol_a)%>
<%=fb.hidden("tipo",tipo)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp","","onSubmit=\"javascript:return(replacePercent(this.searchVal))\"");%>
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
<%=fb.hidden("tr",tr)%>
<%=fb.hidden("wh",wh)%>
<%=fb.hidden("tipo_solicitud",tipo_solicitud)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("fechaini",fechaini)%>
<%=fb.hidden("fechafin",fechafin)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("cod_req",cod_req)%>
<%=fb.hidden("solicitado_por",solicitado_por)%>
<%=fb.hidden("sol_a",sol_a)%>
<%=fb.hidden("tipo",tipo)%>
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
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="3%"></td>
			<td width="4%">A&ntilde;o</td>
			<td width="5%">No. Solicitud</td>
			<td width="5%">Tipo Solicitud</td>
			<td width="10%">Fecha Doc.</td>
			<td width="11%">Creado Por</td>
			<td width="19%">Solicitado por</td>
			<td width="18%">Solicitado a</td>
			<td width="9%">Aprobado por</td>
			<td width="9%">Fecha Aprob.</td>
			<td width="3%">&nbsp;</td>
			<td width="3%">&nbsp;</td>
			<td width="6%">Estado</td>
			<td width="4%">&nbsp;</td>
		</tr>
<%
String colspan = "14";
//if (tr.equalsIgnoreCase("RS")) colspan = "11";
if (request.getParameter("fechaini") == null) {
%>
		<tr class="TextRow01" align="center">
			<td colspan="<%=colspan%>"><font color="#FF0000"> I N T R O D U Z C A &nbsp;&nbsp;&nbsp;&nbsp;P A R A M E T R O S&nbsp;&nbsp;&nbsp;&nbsp;D E&nbsp;&nbsp;&nbsp;&nbsp;B U S Q U E D A</font></td>
		</tr>
<% } else if (al.size() == 0) { %>
		<tr class="TextRow01" align="center">
			<td colspan="<%=colspan%>"><font color="#FF0000"> N O &nbsp; E X I S T E N &nbsp; R E G I S T R O S</font></td>
		</tr>
<% } %>
<%
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
            <td align="right"><%=preVal + i%>&nbsp;</td>
			<td align="center"><%=cdo.getColValue("anio")%></td>
			<td align="center"><%=cdo.getColValue("solicitud_no")%></td>
			<td align="center"><%=cdo.getColValue("desc_tipo_solicitud")%></td>
			<td align="center"><%=cdo.getColValue("fecha_docto")%></td>
			<td align="center"><%=cdo.getColValue("usuario_creacion")%></td>
			<% if (tr.equalsIgnoreCase("EA") || (tr.equalsIgnoreCase("RS") && tipo.equalsIgnoreCase("EA"))) { %>
			<td align="left"><%=cdo.getColValue("solicitado_a")%></td>
			<td align="left"><%=cdo.getColValue("solicitado_por")%></td>
			<% } else { %>
			<td align="left"><%=cdo.getColValue("solicitado_por")%></td>
			<td align="left"><%=cdo.getColValue("solicitado_a")%></td>
			<% } %>
			<td align="left"><%=cdo.getColValue("usuarioAprob")%></td>
			<td align="center"><%=cdo.getColValue("fecha_aprob")%></td>
			
			<td align="center"><% if (cdo.getColValue("estado_solicitud") != null && !cdo.getColValue("estado_solicitud").equalsIgnoreCase("N") && !cdo.getColValue("estado_solicitud").equalsIgnoreCase("R")) { %><authtype type='2'><a href="javascript:showReq(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("solicitud_no")%>,'<%=cdo.getColValue("tipo_solicitud")%>')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><img src="../images/printer.gif" border="0" width="20" height="20"></a></authtype><% } %></td>
			<td align="center">
<% if (!tr.equalsIgnoreCase("RS")) { %>
	<% if (cdo.getColValue("estado_solicitud") != null && (cdo.getColValue("estado_solicitud").equalsIgnoreCase("T") || cdo.getColValue("estado_solicitud").equalsIgnoreCase("P"))) { %>
				<authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("solicitud_no")%>,'<%=cdo.getColValue("tipo_solicitud")%>')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><img src="../images/notes.gif" border="0" width="20" height="20" alt="Editar"></a></authtype>
	<% } else { %>
				<authtype type='1'><a href="javascript:ver(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("solicitud_no")%>,'<%=cdo.getColValue("tipo_solicitud")%>')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><img src="../images/search.gif" border="0" width="20" height="20" alt="Ver"></a></authtype>
	<% } %>
<% } else { %>
	<% if (cdo.getColValue("estado_solicitud") != null && (cdo.getColValue("estado_solicitud").equalsIgnoreCase("T") || cdo.getColValue("estado_solicitud").equalsIgnoreCase("A"))) { %>
				<authtype type='5'><a href="javascript:ver(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("solicitud_no")%>,'<%=cdo.getColValue("tipo_solicitud")%>')"class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">RECHAZAR</a></authtype>
	<% } %>
<% } %>
			</td>
			<td align="center">
<% if (!tr.equalsIgnoreCase("RS")) { %>
	<% if (cdo.getColValue("estado_solicitud") != null && (cdo.getColValue("estado_solicitud").equalsIgnoreCase("T") || cdo.getColValue("estado_solicitud").equalsIgnoreCase("P"))) { %>
				<%=cdo.getColValue("desc_estado")%>
				<authtype type='6'><a href="javascript:approve(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("mes")%>,<%=cdo.getColValue("solicitud_no")%>,'<%=cdo.getColValue("tipo_solicitud")%>','<%=cdo.getColValue("codigo_almacen")%>')"class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Aprobar</a></authtype>
	<% } else { %>
				<%=cdo.getColValue("desc_estado")%><!--Aprobado-->
	<% } %>
<% } else if (tr.equalsIgnoreCase("RS")) { %>
				<%=cdo.getColValue("desc_estado")%><!--Aprobado-->
<% } %>
			</td>
			<td><% if (cdo.getColValue("entregar") != null && cdo.getColValue("entregar").equalsIgnoreCase("S") && !tr.equalsIgnoreCase("RS")) { %><authtype type='50'><a href="javascript:entregar(<%=cdo.getColValue("anio")%>,'<%=cdo.getColValue("tipo_solicitud")%>',<%=cdo.getColValue("solicitud_no")%>,<%=cdo.getColValue("compania")%>)"class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Entregar</a></authtype><% } %></td>
		</tr>
<% } %>
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
<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp","","onSubmit=\"javascript:return(replacePercent(this.searchVal))\"");%>
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
<%=fb.hidden("tr",tr)%>
<%=fb.hidden("wh",wh)%>
<%=fb.hidden("tipo_solicitud",tipo_solicitud)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("fechaini",fechaini)%>
<%=fb.hidden("fechafin",fechafin)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("cod_req",cod_req)%>
<%=fb.hidden("solicitado_por",solicitado_por)%>
<%=fb.hidden("sol_a",sol_a)%>
<%=fb.hidden("tipo",tipo)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp","","onSubmit=\"javascript:return(replacePercent(this.searchVal))\"");%>
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
<%=fb.hidden("tr",tr)%>
<%=fb.hidden("wh",wh)%>
<%=fb.hidden("tipo_solicitud",tipo_solicitud)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("fechaini",fechaini)%>
<%=fb.hidden("fechafin",fechafin)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("cod_req",cod_req)%>
<%=fb.hidden("solicitado_por",solicitado_por)%>
<%=fb.hidden("sol_a",sol_a)%>
<%=fb.hidden("tipo",tipo)%>
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