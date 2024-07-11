<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.StringTokenizer" %>
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

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

boolean isFpEnabled = CmnMgr.isValidFpType("PAC");
ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String clientId = request.getParameter("clientId");
String fecha_ini_plan = request.getParameter("fecha_ini_plan");
String codigo = request.getParameter("codigo");
String nombre = request.getParameter("nombre");
String apellido = request.getParameter("apellido");
String vip = request.getParameter("vip");
String cedulaPasaporte = request.getParameter("cedulaPasaporte");
String status = request.getParameter("status");
String huella = request.getParameter("huella");
String contrato = request.getParameter("contrato");
String tipo_clte = request.getParameter("tipo_clte");
String tipo = request.getParameter("tipo");
String parentesco = request.getParameter("parentesco");
int iconHeight = 32;
int iconWidth = 32;
String fp = request.getParameter("fp");

if (fp == null) fp = "";
if (clientId == null) clientId = "";
if (fecha_ini_plan == null) fecha_ini_plan = "";//CmnMgr.getCurrentDate("dd/mm/yyyy");
if (codigo == null) codigo = "";
if (nombre == null) nombre = "";
if (apellido == null) apellido = "";
if (vip == null) vip = "";
if (cedulaPasaporte == null) cedulaPasaporte = "";
if (status == null) status = "A";
if (huella == null) huella = "";
if (contrato == null) contrato = "";
if (tipo_clte == null) tipo_clte = "";
if (parentesco == null) parentesco = "";
System.out.println("tipo......................"+tipo);
if ((tipo == null || tipo.equals("")) && fp.equals("cxc")) tipo = "R";
else if (tipo == null && !fp.equals("cxc")) tipo = "";
//else tipo = "";

if (!codigo.trim().equals("")) { sbFilter.append(" and id_cliente="); sbFilter.append(codigo); }
if (!nombre.trim().equals("")) { sbFilter.append(" and responsable like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
if (!status.trim().equals("")) { sbFilter.append(" and estado='"); sbFilter.append(status); sbFilter.append("'"); }
if (!contrato.trim().equals("")) { sbFilter.append(" and id = "); sbFilter.append(contrato);}




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

	
	sbSql.append("select a.*, (monto_factura-pagos+ajustes) saldo from (select a.id, a.id_cliente, a.estado, (select nombre_paciente from vw_pm_cliente c where c.codigo = a.id_cliente) responsable, a.cuota_mensual, to_char(a.fecha_ini_plan, 'dd/mm/yyyy') fecha_ini_plan, nvl(num_pagos, 0) hist_pagos, getpagadohasta(a.id) pagado_hasta, nvl(f.cant_facturas, 0) cant_facturas, nvl(f.monto_factura, 0) monto_factura, nvl(f.monto_apl_regtran, 0) pagos, nvl(c.ajustes, 0) ajustes, cant_cuota_extra, cant_adendas, cant_mod_estado, getFactCanceladas(a.id) facturas_canceladas, (case when nvl(num_pagos, 0) > 0 then to_char(add_months(fecha_ini_plan, (num_pagos-1)), 'yyyy/mm') else '' end) hist_pagado_hasta from tbl_pm_solicitud_contrato a, (select id_sol_contrato, count(*) cant_facturas, sum (monto) monto_factura, sum (monto_apl_regtran) monto_apl_regtran from tbl_pm_factura f where f.estado = 'A' and nvl (observacion, 'NA') != 'S/I' group by id_sol_contrato) f, (select id_solicitud, sum (debito - credito) ajustes from tbl_pm_ajuste a, tbl_pm_ajuste_det b where a.id = b.id and a.estado = 'A' and tipo_ben = 1 and tipo_aju in (1, 3, 5) group by id_solicitud) c, (select id_contrato, sum(case when tipo_cambio in (4, 5) then 1 else 0 end) cant_cuota_extra, sum(case when tipo_cambio in (6, 7) then 1 else 0 end) cant_adendas, sum(case when tipo_cambio in (2, 3) then 1 else 0 end) cant_mod_estado from tbl_pm_aud_contrato group by id_contrato) ca where a.estado in ('A', 'F') and a.id = f.id_sol_contrato(+) and a.id = c.id_solicitud(+) and a.id = ca.id_contrato(+)");
	if (!fecha_ini_plan.trim().equals("")) { sbSql.append(" and  fecha_ini_plan = to_date('"); sbSql.append(fecha_ini_plan);sbSql.append("', 'dd/mm/yyyy')");}
	sbSql.append(") a where id is not null");
	sbSql.append(sbFilter.toString());
	sbSql.append(" order by a.id");
	if(!contrato.equals("")){
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
	if(rowCount==0) pVal=0;
	else pVal=preVal;
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Paciente - '+document.title;
var xHeight=0;
var _height = 0.75;
var _width = 0.80;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,300);}
var ignoreSelectAnyWhere = true;
function printEC(){
		var k=document.result.index.value;
		var clientName=clientId=eval('document.result.clientName'+k).value;
		var clientId=clientId=eval('document.result.clientId'+k).value;
		var contratos=eval('document.result.contrato'+k).value;
		abrir_ventana('../planmedico/print_estado_cuenta.jsp?clientId='+clientId+'&clientName='+clientName+'&contrato='+contratos);
  
}
function setIndex(k){document.result.index.value=k;checkOne('result','check',<%=al.size()%>,eval('document.result.check'+k),0);
document.getElementById("cContratoId").value=eval('document.result.contrato'+k).value;}
function goOption(option){
	var k=document.result.index.value;
	var clientId='';
	var status ='';
	if(k!='')
	{
		clientId=eval('document.result.clientId'+k).value;
		showFac=eval('document.result.showFac'+k).value;
		status=eval('document.result.status'+k).value;
	}
	if(option==undefined)alert('La opción no está definida todavía.\nPor favor consulte con su Administrador!');
	else
	{
		if(k=='')alert('Por favor seleccione un contrato antes de ejecutar una acción!');
		else
		{
			var msg='';
			var fecha_ini_plan=eval('document.result.fecha_ini_plan'+k).value;
			var codClie=eval('document.result.codClie'+k).value;
			var clientName=eval('document.result.clientName'+k).value;
			if(option==1)abrir_ventana('../planmedico/pm_cliente_config.jsp?mode=edit&clientId='+clientId+'&clientName='+clientName+'&showFac='+showFac+'&fp=<%=fp%>');
			else if(option==3)abrir_ventana('../planmedico/pm_cliente_config.jsp?mode=view&clientId='+clientId+'&clientName='+clientName+'&showFac='+showFac+'&fp=<%=fp%>');
			else if(option==5)showPopWin('../process/pm_upd_pac_id.jsp?code='+clientId,winWidth*_width,winHeight*_height,null,null,'');
			
		}//admision selected
	}  
}

<!-- W I N D O W S -->
//Windows Size and Position
var _winWidth=screen.availWidth*0.35;
var _winHeight=screen.availHeight*0.26;
var _winPosX=(screen.availWidth-_winWidth)/2;
var _winPosY=(screen.availHeight-_winHeight)/2;
var _popUpOptions='toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width='+_winWidth+',height='+_winHeight+',top='+_winPosY+',left='+_winPosX;

function showForm(contrato, clientId, tipo){
		if(tipo=='C') abrir_ventana('../planmedico/reg_solicitud.jsp?mode=view&id='+contrato);
		else if(tipo=='F')abrir_ventana('../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_pm_form_liq_reclamo.rptdesign&idParam='+clientId+'&contParam='+contrato+'&pCtrlHeader=true');
}

function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 3:msg='Ver Modificaciones al contrato'+(getCurClientId()!=""?" #"+getCurClientId():"");break;
		case 4:msg='Imprimir Estado de Cuenta'+(getCurClientId()!=""?" #"+getCurClientId():"");break;
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

function getCurClientId(){return document.getElementById("cContratoId").value;}

function showModContrato(id, tipo){
	showPopWin('../process/pm_view_mod_contrato.jsp?tipo='+tipo+'&contrato='+id,winWidth*.75,winHeight*.65,null,null,'');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLAN MEDICO - CLIENTES - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right">
		<div id="optDesc" class="TextInfo Text10">&nbsp;</div>
		<!--<authtype type='1'><a href="javascript:goOption(3)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/ver.png"></a></authtype>-->
		<authtype type='50'><a href="javascript:printEC()"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" src="../images/imprimir_analisis.png"  onMouseOver="javascript:mouseOver(this,4)" onMouseOut="javascript:mouseOut(this,4)" ></a></authtype>
	</td>
</tr>
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextFilter">
		<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("fp",fp)%>
			<td>
				<cellbytelabel id="2">Fecha Inicio Pan.</cellbytelabel>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="fecha_ini_plan" />
				<jsp:param name="valueOfTBox1" value="<%=fecha_ini_plan%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				<jsp:param name="clearOption" value="true" />
				</jsp:include>
				<cellbytelabel id="3">Contrato</cellbytelabel>
				<%=fb.intBox("contrato",contrato,false,false,false,10,20,"Text10",null,null)%>
				<cellbytelabel id="4">Responsable</cellbytelabel>
				<%=fb.textBox("nombre",nombre,false,false,false,30,"Text10",null,"")%>
				<cellbytelabel id="8">Estado</cellbytelabel>
				<%=fb.select("status","A=ACTIVO,I=INACTIVO",status,false,false,0,"Text10",null,null,null,"T")%>
				<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
			</td>
<%=fb.formEnd(true)%>
		</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
<%=fb.hidden("fecha_ini_plan",fecha_ini_plan)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("contrato",contrato)%>
<%=fb.hidden("fp",fp)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel id="10">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="11">Registros desde </cellbytelabel> <%=pVal%><cellbytelabel id="12"> hasta</cellbytelabel> <%=nVal%></td>
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
<%=fb.hidden("fecha_ini_plan",fecha_ini_plan)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("contrato",contrato)%>
<%=fb.hidden("fp",fp)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
		<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="list" exclude="8,9">
		<tr class="TextHeader" align="center">
			<td width="5%"><cellbytelabel id="3">Contrato</cellbytelabel></td><!---->
			<td width="12%"><cellbytelabel id="1">Responsable</cellbytelabel></td>
			<td width="6%"><cellbytelabel id="2">Fecha Ini. Plan</cellbytelabel></td>
			<td width="6%"><cellbytelabel id="2">Fact. Cancel.</cellbytelabel></td>
			<td width="6%"><cellbytelabel id="7">Hist. Pagos</cellbytelabel></td>
			<td width="6%"><cellbytelabel id="7">Hist. Pagado Hasta</cellbytelabel></td>
			<td width="6%"><cellbytelabel id="4">Pagado Hasta</cellbytelabel></td>
			<td width="6%"><cellbytelabel id="5">Cuota</cellbytelabel></td>
			<td width="6%"><cellbytelabel id="13">Cant. Fact.</cellbytelabel></td>
			<td width="6%"><cellbytelabel id="14">Monto Fact.</cellbytelabel></td>
			<td width="6%"><cellbytelabel id="15">Pagos</cellbytelabel></td>
			<td width="6%"><cellbytelabel id="16">Ajustes (DB/CR/DESC.)</cellbytelabel></td>
			<td width="6%"><cellbytelabel id="20">Saldo</cellbytelabel></td>
			<td width="6%"><cellbytelabel id="17"># Cuotas Extra.</cellbytelabel></td>
			<td width="6%"><cellbytelabel id="18"># Adendas</cellbytelabel></td>
			<td width="6%"><cellbytelabel id="19"># Mod. Estado</cellbytelabel></td>
			<td width="5%"><cellbytelabel id="8">Estado</cellbytelabel></td>
			<td width="3%">&nbsp;</td>
		</tr>
<%fb = new FormBean("result",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("index","")%>
<%=fb.hidden("cContratoId","")%>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("clientId"+i,cdo.getColValue("id_cliente"))%>
		<%=fb.hidden("fecha_ini_plan"+i,cdo.getColValue("fecha_ini_plan"))%>
		<%=fb.hidden("contrato"+i,cdo.getColValue("id"))%>
		<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
		<%=fb.hidden("clientName"+i,cdo.getColValue("nombre_paciente"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("id")%></td>
			<td align="center"><%=cdo.getColValue("responsable")%></td>
			<td align="center"><%=cdo.getColValue("fecha_ini_plan")%></td>
			<td align="center"><%=cdo.getColValue("facturas_canceladas")%></td>
			<td align="center"><%=cdo.getColValue("hist_pagos")%></td>
			<td align="center"><%=cdo.getColValue("hist_pagado_hasta")%></td>
			<td align="center"><%=cdo.getColValue("pagado_hasta")%></td>
			<td align="center"><%=cdo.getColValue("cuota_mensual")%></td>
			<td align="center"><%=cdo.getColValue("cant_facturas")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_factura"))%>&nbsp;&nbsp;&nbsp;&nbsp;</td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("pagos"))%>&nbsp;&nbsp;&nbsp;&nbsp;</td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ajustes"))%>&nbsp;&nbsp;&nbsp;&nbsp;</td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("saldo"))%>&nbsp;&nbsp;&nbsp;&nbsp;</td>
			<td align="center" style="cursor:pointer" onDblClick="javascript:showModContrato(<%=cdo.getColValue("id")%>,'CE');"><%=cdo.getColValue("cant_cuota_extra")%></td>
			<td align="center" style="cursor:pointer" onDblClick="javascript:showModContrato(<%=cdo.getColValue("id")%>,'AD');"><%=cdo.getColValue("cant_adendas")%></td>
			<td align="center" style="cursor:pointer" onDblClick="javascript:showModContrato(<%=cdo.getColValue("id")%>,'ME');"><%=cdo.getColValue("cant_mod_estado")%></td>
			<td align="center"><%=(cdo.getColValue("estado").equalsIgnoreCase("A"))?"ACTIVO":"FINALIZADO"%></td>
			<td align="center"><%=fb.checkbox("check"+i,"",false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%></td>
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
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
<%=fb.hidden("clientId",clientId)%>
<%=fb.hidden("fecha_ini_plan",fecha_ini_plan)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("contrato",contrato)%>
<%=fb.hidden("fp",fp)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel id="10">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="11">Registros desde</cellbytelabel>  <%=pVal%><cellbytelabel id="12"> hasta</cellbytelabel> <%=nVal%></td>
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
<%=fb.hidden("fecha_ini_plan",fecha_ini_plan)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("contrato",contrato)%>
<%=fb.hidden("fp",fp)%>
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