<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.inventory.Delivery"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="DelMgr" scope="page" class="issi.inventory.DeliveryMgr"/>
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
DelMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList alWh = new ArrayList();
int rowCount = 0;
String sql = "";
StringBuffer appendFilter = new StringBuffer();
String wh = request.getParameter("wh");
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String solicitadoPor = request.getParameter("solicitadoPor");
if(solicitadoPor==null) solicitadoPor = "";
if(fp==null) fp = "";
if(fg==null) fg = "UA";
String popWinFunction = "abrir_ventana";
if(fp.trim().equals("EA")) popWinFunction = "abrir_ventana2";

/*====================================================================================*/
/*====================================================================================*/
/*  fg = TIPO DE ENTREGA  */
/*
	fg = UA - Materiales y Equipos para Unidades Administrativas
	fg = EC - Transferencia entre Compañias
	fg = EA - Transferencia entre Almacenes
	fg = MP - Materiales para Pacientes
*/
/*====================================================================================*/

alWh = sbb.getBeanList(ConMgr.getConnection(), "select codigo_almacen as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania="+(String) session.getAttribute("_companyId")+" order by codigo_almacen", CommonDataObject.class);
if (wh == null ) wh ="";
if(!wh.trim().equals("")){appendFilter.append(" and a.codigo_almacen=");appendFilter.append(wh);}


if(request.getMethod().equalsIgnoreCase("GET"))
{
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
String req_anio = "", requisicion ="";
	if (request.getParameter("anio") != null && !request.getParameter("anio").trim().equals(""))
	{
		appendFilter.append(" and a.anio =");appendFilter.append(request.getParameter("anio"));
		/*searchOn = "a.anio";
		searchVal = request.getParameter("anio");
		searchType = "1";
		searchDisp = "Año";*/
	}
	if (request.getParameter("entrega") != null && !request.getParameter("entrega").trim().equals(""))
	{
	appendFilter.append(" and a.no_entrega = ");appendFilter.append(request.getParameter("entrega"));
		/*
		searchOn = "a.no_entrega";
		searchVal = request.getParameter("entrega");
		searchType = "1";
		searchDisp = "No. Entrega";
	*/
	}
	if (request.getParameter("requisicion") != null && !request.getParameter("requisicion").trim().equals(""))
	{
		requisicion = request.getParameter("requisicion");
		if(!fg.equals("MP")){
	appendFilter.append(" and upper(a.req_solicitud_no) like '%");appendFilter.append(request.getParameter("requisicion").toUpperCase());appendFilter.append("%'");
		//searchOn = "a.req_solicitud_no";
	}else{
	appendFilter.append(" and upper(a.pac_solicitud_no) like '%");appendFilter.append(request.getParameter("requisicion").toUpperCase());appendFilter.append("%'");
	}
	/*
	searchOn = "a.pac_solicitud_no";
		searchVal = request.getParameter("requisicion");
		searchType = "1";
		searchDisp = "No. Requisicion";
		 */
	}
	 if (request.getParameter("req_anio") != null && !request.getParameter("req_anio").trim().equals(""))
	{
		req_anio = request.getParameter("req_anio");
	if(!fg.equals("MP")){
	appendFilter.append(" and a.req_anio = ");appendFilter.append(request.getParameter("req_anio"));
		//searchOn = "a.req_anio";
	}else
	{
	appendFilter.append(" and a.pac_anio = ");appendFilter.append(request.getParameter("req_anio"));
		}
	/*
	searchOn = "a.pac_anio";
		searchVal = request.getParameter("req_anio");
		searchType = "1";
		searchDisp = "Año Requisicion";
	*/
	}
	if (request.getParameter("fechaini") != null && !request.getParameter("fechaini").trim().equals(""))
	{
		appendFilter.append(" and to_date(to_char(a.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date('");appendFilter.append(request.getParameter("fechaini"));appendFilter.append("','dd/mm/yyyy')");
		/*
	searchOn = "a.fecha_entrega";
		searchValFromDate = request.getParameter("fechaini");
		searchType = "2";
		searchDisp = "Fecha Entrega";
	and to_date(to_char(sr.fecha_creacion,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+fechafin+"','dd/mm/yyyy') ";
	*/
	}
	 if (request.getParameter("fechafin") != null && !request.getParameter("fechafin").trim().equals(""))
	{
		appendFilter.append(" and to_date(to_char(a.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('");appendFilter.append(request.getParameter("fechafin"));appendFilter.append("','dd/mm/yyyy')");
		/*
	searchOn = "a.fecha_entrega";
		searchValFromDate = request.getParameter("fechaini");
		searchType = "2";
		searchDisp = "Fecha Entrega";
	and to_date(to_char(sr.fecha_creacion,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+fechafin+"','dd/mm/yyyy') ";
	*/
	}
	/*else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
	{
	 if (searchType.equals("1"))
	 {
		 appendFilter.append(" and upper(");appendFilter.append(searchOn);appendFilter.append(") like '%");appendFilter.append(searchVal.toUpperCase());appendFilter.append("%'");
	 }else if (searchType.equals("2"))
		appendFilter.append(" and to_date(to_char(");appendFilter.append(searchOn);appendFilter.append(",'dd/mm/yyyy'),'dd/mm/yyyy') = to_date('");appendFilter.append(searchValFromDate);appendFilter.append("','dd/mm/yyyy')");
	}
	else
	{
		searchOn="SO";
		searchVal="Todos";
		searchType="ST";
		searchDisp="Listado";
	}*/

	String fgFilter = "",t_s ="";
	if(fg.equals("UA")){
		fgFilter = " a.pac_anio is null and a.pac_solicitud_no is null and sr.tipo_transferencia = 'U' and a.compania_sol = sr.compania and  sr.compania=al.compania and ";
	t_s = "S=Semanal";
	} else if(fg.equals("MP")){
		fgFilter = "a.pac_anio is not null and a.pac_solicitud_no is not null and ";
	} else if(fg.equals("EC")){
	fgFilter =" a.compania_sol = sr.compania and sr.tipo_transferencia = 'C' and sr.compania_sol = al.compania and ";
	t_s = "S=Semanal";
	} else if(fg.equals("EA")){
	fgFilter = "a.compania =sr.compania and sr.tipo_transferencia = 'A' and  sr.compania=al.compania and ";
	t_s = "D=Diaria";
	}
	
	if(!fg.equals("MP"))if(!solicitadoPor.equals("")){
		appendFilter.append(" and decode(sr.tipo_transferencia,'U',decode(a.unidad_administrativa,'7',decode(sr.codigo_centro,null,c.codigo||' '||c.descripcion,c.descripcion||' -- '||cs.codigo||' '||cs.descripcion),c.codigo||' '||c.descripcion ) ,'A', al.codigo_almacen||' '||al.descripcion,'C',c.codigo||' '||c.descripcion) like '%");
		appendFilter.append(solicitadoPor);
		appendFilter.append("%'");
	}
	 


	if(!appendFilter.toString().trim().equals(""))
	{
	sql = "select a.anio, a.no_entrega as noEntrega, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi am') as fechaEntrega, a.unidad_administrativa as unidadAdministrativa, a.req_anio as reqAnio, a.req_tipo_solicitud as reqTipoSolicitud, decode(a.req_tipo_solicitud,'D','DIARIA','S','SEMANAL','Q','QUINCENAL','M','MENSUAL') as reqTipoSolicitudDesc, a.req_solicitud_no as reqSolicitudNo, a.codigo_almacen as codigoAlmacen, b.descripcion as nombreAlmacen, decode(sr.tipo_transferencia,'U',decode(a.unidad_administrativa,'7',decode(sr.codigo_centro,null,c.codigo||' '||c.descripcion,c.descripcion||' -- '||cs.codigo||' '||cs.descripcion),c.codigo||' '||c.descripcion ) ,'A', al.codigo_almacen||' '||al.descripcion,'C',c.codigo||' '||c.descripcion)  as unidadAdminDesc,sr.codigo_almacen reqCodAlmacen , nvl(a.observaciones,' ') as observaciones   from tbl_inv_entrega_material a,tbl_inv_almacen al, tbl_inv_almacen b, tbl_sec_unidad_ejec c,tbl_inv_solicitud_req sr,tbl_cds_centro_servicio cs where "+fgFilter+"  a.req_anio = sr.anio  and a.req_tipo_solicitud = sr.tipo_solicitud and a.req_solicitud_no = sr.solicitud_no and sr.codigo_almacen=al.codigo_almacen and a.codigo_almacen = b.codigo_almacen and a.compania = b.compania and a.compania_sol=c.compania(+) and a.unidad_administrativa=c.codigo(+) and a.compania="+(String) session.getAttribute("_companyId")+appendFilter.toString()+" and cs.codigo(+) = sr.codigo_centro  order by a.codigo_almacen asc, a.anio desc,a.no_entrega desc";

	if(fg.equals("MP")){
		sql = "select a.anio, a.no_entrega as noEntrega, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi am') as fechaEntrega, nvl(a.unidad_administrativa, 0) as unidadAdministrativa, a.pac_anio as reqAnio, a.req_tipo_solicitud as reqTipoSolicitud, decode(a.req_tipo_solicitud,'D','DIARIA','S','SEMANAL','Q','QUINCENAL','M','MENSUAL', ' ') as reqTipoSolicitudDesc, a.pac_solicitud_no as reqSolicitudNo, a.codigo_almacen as codigoAlmacen, b.descripcion as nombreAlmacen, ' ' as unidadAdminDesc, c.primer_nombre||decode(c.segundo_nombre,null,'',' '||c.segundo_nombre)||decode(c.primer_apellido,null,'',' '||c.primer_apellido)||decode(c.segundo_apellido,null,'',' '||c.segundo_apellido)||decode(c.sexo,'F',decode(c.apellido_de_casada,null,'',' '||c.apellido_de_casada)) as paciente, nvl(d.descripcion,' ') centroServDesc , 0 reqCodAlmacen, nvl(a.observaciones,' ') as observaciones  from tbl_inv_entrega_material a, tbl_inv_almacen b, tbl_adm_paciente c, tbl_cds_centro_servicio d where "+fgFilter+" a.compania=b.compania and a.codigo_almacen=b.codigo_almacen and a.compania="+(String) session.getAttribute("_companyId")+appendFilter.toString()+" and a.pac_id = c.pac_id(+) and a.centro_servicio = d.codigo(+) order by a.codigo_almacen  asc, a.anio desc ,a.no_entrega desc";
	}
	System.out.println("sql="+sql);

	al = sbb.getBeanList(ConMgr.getConnection(), "select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal, Delivery.class);
	rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
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
document.title = 'Inventario - Entrega - '+document.title;

function add()
{
	<%=popWinFunction%>('../inventario/reg_delivery.jsp?fg=<%=fg%>&fp=<%=fp%>');
}

function view(anio, no)
{
	<%if(fg != null && fg.trim().equals("MP")){%>
	<%=popWinFunction%>('../inventario/reg_delivery.jsp?mode=view&fg=<%=fg%>&fp=<%=fp%>&anio='+anio+'&no='+no);
	<%}else{ %>
	<%=popWinFunction%>('../inventario/vw_delivery.jsp?fg=<%=fg%>&fp=<%=fp%>&anio='+anio+'&no='+no);
	<%}%>
}

function printList()

{
	<% if ((appendFilter != null || !appendFilter.toString().trim().equals("")) && al.size() != 0){%>
	<%=popWinFunction%>('print_list_delivery.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter.toString())%>&fg=<%=fg%>&fp=<%=fp%>');
	<%}else{%>
	alert('I N T R O D U Z C A     P A R Á M E T R O S    D E    B Ú S Q U E D A');
	<%}%>
}


function getMain(formX)
{
	formX.wh.value = document.searchMain.wh.value;
	return true;
}
function reporte(anio,id)
{
var tr ='';
var fg='';
<%if(fg.equals("UA")){%>
tr='U';
<%=popWinFunction%>('../inventario/print_entregas.jsp?fg='+fg+'&fp=<%=fp%>&tr='+tr+'&anioEntrega='+anio+'&noEntrega='+id);

<%}else if(fg.equals("EA")){%>
tr='A';
//<%=popWinFunction%>('../inventario/print_entregas_almacenes.jsp?fg=EA&fp=<%=fp%>&tr='+tr+'&anioEntrega='+anio+'&noEntrega='+id);
<%=popWinFunction%>('../inventario/print_entregas.jsp?fg='+fg+'&fp=<%=fp%>&tr='+tr+'&anioEntrega='+anio+'&noEntrega='+id);
<%}%>
}
function showReq(anio,id,wh,tipo)
{
 <%if(fg.equals("UA")){%>
 <%=popWinFunction%>('../inventario/print_requisiciones_unidades_adm.jsp?fg=UA&tr=RQ&fp=<%=fp%>&anio='+anio+'&cod_req='+id+'&almacen='+wh+'&tipo='+tipo);
 <%}else if(fg.equals("MP")){%>
	<%=popWinFunction%>('../inventario/print_solicitud_pac.jsp?fg=RUA&tr=RQ&fp=<%=fp%>&anio='+anio+'&id='+id);
	 <%}else if(fg.equals("EA")){%>
	<%=popWinFunction%>('../inventario/print_sol_req_almacenes.jsp?fg=REA&fp=EA&anio='+anio+'&cod_req='+id+'&almacen='+wh);
	 <%}else if(fg.equals("EC")){%>
 // abrir_ventana('../inventario/print_list_requisiciones.jsp?fg=REC&anio='+anio+'&id='+id+'&almacen='+wh);
	<%}%>
}

var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}

$(function(){
  $(".observaciones").tooltip({
	content: function () {
	  var $i = $(this).data("i");
	  var $title = $($(this).prop('title'));
	  var $content = $("#observCont"+$i).val();
	  var $cleanContent = $($content).text();
	  if (!$cleanContent) $content = "";
	  return $content;
	}
	,track: true
  });
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%if(!fp.trim().equals("EA")){%>
<%@ include file="../common/menu_base.jsp"%>
<%}%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - TRANSACCIONES - ENTREGAS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
	<tr>
		<td align="right">
<%
if(!fp.equals("EA")){%>

	<authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nueva Entrega ]</a></authtype>

<%}%>
		&nbsp;
		</td>
	</tr>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<%fb = new FormBean("searchMain",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>

	<tr class="TextFilter">
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("fp",fp)%>
		 <td>
			Almac&eacute;n
		 <%if(fg.equals("MP")){%>
			<%=fb.select("wh",alWh,wh,"T")%>
		<%}else {%>
		<%=fb.select("wh",alWh,wh,"T")%>
		<%}%>
Fecha:&nbsp;&nbsp;
			<jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="2"/>
			<jsp:param name="clearOption" value="true"/>
			<jsp:param name="nameOfTBox1" value="fechaini"/>
			<jsp:param name="valueOfTBox1" value=""/>
			<jsp:param name="nameOfTBox2" value="fechafin"/>
			<jsp:param name="valueOfTBox2" value=""/>
		</jsp:include>
</td>
	</tr>

	<tr class="TextFilter">
		<td>
			Año Entrega
			<%=fb.textBox("anio","",false,false,false,4,4,null,null,null)%>
			No. Entrega
			<%=fb.textBox("entrega","",false,false,false,15,null,null,null)%>
			Año Requisici&oacute;n
			<%=fb.textBox("req_anio",req_anio,false,false,false,4,4,null,null,null)%>
			No. Requisici&oacute;n
			<%=fb.textBox("requisicion",requisicion,false,false,false,15,null,null,null)%>
			Solicitado Por:
			<%=fb.textBox("solicitadoPor",solicitadoPor,false,false,false,25,null,null,null)%>
		 <%=fb.submit("go","Ir")%>
		</td>

	</tr>
	<%=fb.formEnd()%>
	<tr>
		<td align="right">
<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>
		&nbsp;
		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%
				fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
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
				<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("fp",fp)%>
		<%=fb.hidden("wh",wh)%>
		<%=fb.hidden("req_anio",req_anio)%>
		<%=fb.hidden("requisicion",requisicion)%>
		<%=fb.hidden("fechaini",request.getParameter("fechaini"))%>
		<%=fb.hidden("fechafin",request.getParameter("fechafin"))%>
		<%=fb.hidden("entrega",request.getParameter("entrega"))%>
		<%=fb.hidden("anio",request.getParameter("anio"))%>


		 <td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
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
					<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("wh",wh)%>
			<%=fb.hidden("req_anio",req_anio)%>
			<%=fb.hidden("requisicion",requisicion)%>
			<%=fb.hidden("fechaini",request.getParameter("fechaini"))%>
			<%=fb.hidden("fechafin",request.getParameter("fechafin"))%>
			<%=fb.hidden("entrega",request.getParameter("entrega"))%>
			<%=fb.hidden("anio",request.getParameter("anio"))%>
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

<table align="center" width="100%" cellpadding="0" cellspacing="1">
	<tr class="TextHeader02" align="center">
		<td width="3%">&nbsp;</td>
		<td colspan="3">E N T R E  G A</td>
		<td colspan="4">R E Q U I S I C I O N</td>
		<td width="5%">&nbsp;</td>
	<td width="5%">&nbsp;</td>
	</tr>
	<tr class="TextHeader" align="center">
		<td width="3%">&nbsp;</td>
		<!--<td width="4%">A&ntilde;o</td> -->
		<td width="10%">No.</td>
		<td width="14%">Fecha</td>
		<td width="5%">A&ntilde;o</td>
		<td width="10%">No.</td>
		<td width="<%=(fg.equals("MP")?"25":"15")%>%"><%=(fg.equals("MP")?"Nombre":"Tipo Solicitud")%></td>
		<td width="<%=(fg.equals("MP")?"25":"35")%>%"><%=(fg.equals("MP")?"Sala/Centro. Serv.":"Solicitado Por")%></td>
	<td width="5%">&nbsp;</td>
	<td width="5%">&nbsp;</td>
	</tr>

		<% if ((appendFilter == null || appendFilter.toString().trim().equals("")) && al.size() == 0){%>
		<tr class="TextRow01" align="center">
			<td colspan="10">&nbsp; </td>
		</tr>
		<tr class="TextRow01" align="center">
			<td colspan="10"> <font color="#FF0000"> I N T R O D U Z C A &nbsp;&nbsp;&nbsp;&nbsp;P A R Á M E T R O S&nbsp;&nbsp;&nbsp;&nbsp;D E&nbsp;&nbsp;&nbsp;&nbsp;B Ú S Q U E D A</font></td>
		</tr>
		<%}%>


				<%
				String whName = "";
				for (int i=0; i<al.size(); i++)
				{
					Delivery del = (Delivery) al.get(i);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";

					if (!whName.equalsIgnoreCase(del.getNombreAlmacen()))
					{
				%>
				<tr class="TextHeader01">
					<td colspan="10"><%=del.getNombreAlmacen()%></td>
				</tr>
				<%
					}
				%>
				<%=fb.hidden("observCont"+i,"<label class='observCont' style='font-size:11px'>"+(del.getObservaciones()!= null && !del.getObservaciones().equals(" ")?del.getObservaciones():"")+"</label>")%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="right"><%=preVal + i%>&nbsp;</td>
					<!-- <td align="center"><%=del.getAnio()%></td> -->
					<td align="center"><%=del.getNoEntrega()%></td>
					<td align="center"><%=del.getFechaEntrega()%></td>
					<%if(fg.equals("UA") || fg.equals("MP")){ %>
			<td align="center">
			<authtype type='2'><a href="javascript:showReq(<%=del.getReqAnio()%>,<%=del.getReqSolicitudNo()%>,'<%=del.getReqCodAlmacen()%>','<%=del.getReqTipoSolicitud()%>')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><%=del.getReqAnio()%></a></authtype> </td>
					<td align="center"><authtype type='2'><a href="javascript:showReq(<%=del.getReqAnio()%>,<%=del.getReqSolicitudNo()%>,<%=del.getReqCodAlmacen()%>,'<%=del.getReqTipoSolicitud()%>')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><%=del.getReqSolicitudNo()%></a> </authtype></td>
			<%}else{ %>
			<td align="center"><%=del.getReqAnio()%></td>
					<td align="center"><%=del.getReqSolicitudNo()%></td>
			<%} %>

					<td><%=(fg.equals("MP")?del.getPaciente():del.getReqTipoSolicitudDesc())%></td>
					<td>
					  <span class="observaciones" title="" data-i="<%=i%>"><span class="pointer"><%=(fg.equals("MP")?del.getCentroServDesc():del.getUnidadAdminDesc())%></span></span>
					</td>
					
					<td align="center">
					<authtype type='1'><a href="javascript:view(<%=del.getAnio()%>,<%=del.getNoEntrega()%>)" class="Link00" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Ver</a></authtype>

					</td>
			<td align="center">
			 <%if(fg.trim().equals("UA") || fg.trim().equals("EA") ){ %>
			<authtype type='2'> <a href="javascript:reporte(<%=del.getAnio()%>,<%=del.getNoEntrega()%>)" class="Link02Bold"><img src="../images/print_analysis.gif" width="18" height="18" border="0"></a></authtype>
			 <%}%>

			 </td>
				</tr>
				<%
					whName = del.getNombreAlmacen();
				}
				%>

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
				<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("fp",fp)%>
		<%=fb.hidden("wh",wh)%>
		<%=fb.hidden("req_anio",req_anio)%>
		<%=fb.hidden("requisicion",requisicion)%>
		<%=fb.hidden("fechaini",request.getParameter("fechaini"))%>
		<%=fb.hidden("fechafin",request.getParameter("fechafin"))%>
		<%=fb.hidden("entrega",request.getParameter("entrega"))%>
		<%=fb.hidden("anio",request.getParameter("anio"))%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
					<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("wh",wh)%>
			<%=fb.hidden("req_anio",req_anio)%>
			<%=fb.hidden("requisicion",requisicion)%>
			<%=fb.hidden("fechaini",request.getParameter("fechaini"))%>
			<%=fb.hidden("fechafin",request.getParameter("fechafin"))%>
			<%=fb.hidden("entrega",request.getParameter("entrega"))%>
			<%=fb.hidden("anio",request.getParameter("anio"))%>
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
