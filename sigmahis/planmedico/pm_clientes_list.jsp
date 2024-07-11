<%@ page errorPage="../error.jsp"%>
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
String dob = request.getParameter("dob");
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
String tienePacId = request.getParameter("tienePacId");
int iconHeight = 32;
int iconWidth = 32;
String fp = request.getParameter("fp");

if (fp == null) fp = "";
if (clientId == null) clientId = "";
if (dob == null) dob = "";//CmnMgr.getCurrentDate("dd/mm/yyyy");
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
if (tienePacId == null) tienePacId = "";
System.out.println("tipo......................"+tipo);
if ((tipo == null || tipo.equals("")) && fp.equals("cxc")) tipo = "R";
else if (tipo == null && !fp.equals("cxc")) tipo = "";
//else tipo = "";

if (!clientId.trim().equals("")) { sbFilter.append(" and pac_id="); sbFilter.append(clientId); }
if (!dob.trim().equals("")) { sbFilter.append(" and to_char(fecha_nacimiento,'dd/mm/yyyy')='"); sbFilter.append(dob); sbFilter.append("'"); }
if (!codigo.trim().equals("")) { sbFilter.append(" and codigo="); sbFilter.append(codigo); }
if (!nombre.trim().equals("")) { sbFilter.append(" and upper(primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
if (!apellido.trim().equals("")) { sbFilter.append(" and upper(primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada))) like '%"); sbFilter.append(apellido.toUpperCase()); sbFilter.append("%'"); }
if (!vip.trim().equals("")) { sbFilter.append(" and upper(vip)='"); sbFilter.append(vip.toUpperCase()); sbFilter.append("'"); }
if (!cedulaPasaporte.trim().equals("")) { sbFilter.append(" and upper(coalesce(pasaporte,provincia||'-'||sigla||'-'||tomo||'-'||asiento)||'-'||d_cedula) like '%"); sbFilter.append(cedulaPasaporte.toUpperCase()); sbFilter.append("%'"); }
if (!status.trim().equals("")) { sbFilter.append(" and estatus='"); sbFilter.append(status); sbFilter.append("'"); }
if (!huella.trim().equals("") && huella.trim().equals("S")) { sbFilter.append("  and pac_id in (select owner_id from tbl_bio_fingerprint where capture_type = 'PAC') ");}
if (!contrato.trim().equals("")) { sbFilter.append(" and exists (select null from tbl_pm_solicitud_contrato sc, tbl_pm_sol_contrato_det dc where sc.id = dc.id_solicitud and (sc.id_cliente = c.codigo or dc.id_cliente = c.codigo) and sc.id = ");
sbFilter.append(contrato);
sbFilter.append(") ");}
else if (!huella.trim().equals("") && huella.trim().equals("N")) { sbFilter.append("  and pac_id not in (select owner_id from tbl_bio_fingerprint where capture_type = 'PAC') ");}
else sbFilter.append(" ");
if (tienePacId.trim().equals("S")) { sbFilter.append(" and c.pac_id is null");}
else if(tienePacId.trim().equals("N")) { sbFilter.append(" and c.pac_id not is null");}
if (!tipo_clte.trim().equals("")) { sbFilter.append(" and c.tipo_clte='"); sbFilter.append(tipo_clte); sbFilter.append("'"); }
if (tipo!=null && tipo.trim().equals("R")) sbFilter.append(" and exists (select null from tbl_pm_solicitud_contrato sc where sc.id_cliente = c.codigo and sc.estado in ('A', 'F'))");
else if (tipo!=null && tipo.trim().equals("B"))  sbFilter.append(" and exists (select null from tbl_pm_solicitud_contrato sc, tbl_pm_sol_contrato_det dc where sc.estado = 'A' and (dc.estado = 'A' or (dc.estado = 'I' and to_char(sysdate, 'mm/yyyy') = to_char(dc.fecha_finaliza, 'mm/yyyy'))) and sc.id = dc.id_solicitud and dc.id_cliente = c.codigo)");

if (parentesco!=null && !parentesco.trim().equals(""))  {sbFilter.append(" and exists (select null from tbl_pm_solicitud_contrato sc, tbl_pm_sol_contrato_det dc where sc.estado = 'A' and (dc.estado = 'A' or (dc.estado = 'I' and trunc(sysdate) <= last_day(dc.fecha_finaliza))) and sc.id = dc.id_solicitud and dc.id_cliente = c.codigo and dc.parentesco = ");sbFilter.append(parentesco);sbFilter.append(")");}


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

	if(request.getParameter("clientId")!= null){
	sbSql.append("select c.pac_id, to_char(c.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, c.codigo, coalesce(c.pasaporte,c.provincia||'-'||c.sigla||'-'||c.tomo||'-'||c.asiento)||'-'||c.d_cedula as cedulaPasaporte, c.primer_nombre||decode(c.segundo_nombre,null,'',' '||c.segundo_nombre) as nombre, c.primer_apellido||decode(c.segundo_apellido,null,'',' '||c.segundo_apellido)||decode(c.sexo,'F',decode(c.apellido_de_casada,null,'',' '||c.apellido_de_casada)) as apellido, c.sexo, c.estatus, decode(c.VIP,'S','VIP','N','NORMAL','D','DISTINGUIDO','M','MEDICO STAFF','J','J.DIRECTIVA') as pFidelizacion, c.pasaporte, c.provincia, c.sigla, c.tomo, c.asiento, c.d_cedula,(select count(s.id_cliente) from tbl_pm_solicitud_contrato s, tbl_pm_sol_contrato_det d where  s.fecha_ini_plan is not null and d.estado = 'A' and s.id = d.id_solicitud and s.id_cliente = d.id_cliente and d.id_cliente = codigo) showFac, /*join(cursor(select distinct sc.id||'-'||dc.no_contrato from tbl_pm_solicitud_contrato sc, tbl_pm_sol_contrato_det dc where sc.estado in ('P', 'A') and sc.id = dc.id_solicitud and (sc.id_cliente = c.codigo or dc.id_cliente = c.codigo)), ', ')*/ getnocontrato(c.codigo, '");
	sbSql.append(tipo.equals("")?"T":tipo);
	sbSql.append("') contrato, NVL((select count(*) from tbl_pm_solicitud_contrato sc where sc.id_cliente = c.codigo and sc.estado in('A','F')), 0) num_cont_resp, getnocuotas(c.codigo, '");
	sbSql.append(tipo.equals("")?"T":tipo);
	sbSql.append("') cuotas_iniciales");
	sbSql.append(" from tbl_pm_cliente c where c.codigo is not null ");
		sbSql.append(sbFilter);
	sbSql.append(" order by pac_id desc");
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
function printList(){
  var appendFilter = "<%=IBIZEscapeChars.forURL(sbFilter.toString())%>";
  //if (getCurClientId() != "") appendFilter = "+and+codigo%3D"+getCurClientId()+"+";
	var dob = document.search00.dob.value||'ALL';
	var clientId = document.search00.clientId.value||'ALL';
	var codigo = document.search00.codigo.value||'ALL';
	var contrato = document.search00.contrato.value||'ALL';
	var nombre = document.search00.nombre.value||'ALL';
	var apellido = document.search00.apellido.value||'ALL';
	var cedulaPasaporte = document.search00.cedulaPasaporte.value||'ALL';
	var status = document.search00.status.value||'ALL';
	var tipo_clte = document.search00.tipo_clte.value||'ALL';
	var parentesco = document.search00.parentesco.value||'ALL';
	var tipo = document.search00.tipo.value||'ALL';
	var parentesco = document.search00.parentesco.value||'ALL';
	var tienePacId = (document.search00.tienePacId.checked?'S':'ALL');
	abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_pm_cliente_list.rptdesign&fNacParam='+dob+'&tipoParam='+tipo+'&estadoParam='+status+'&contratoParam='+contrato+'&codigoParam='+codigo+'&nombreParam='+nombre+'&apellidoParam='+apellido+'&tipoClienteParam='+tipo_clte+'&parentescoParam='+parentesco+'&identificacionParam='+cedulaPasaporte+'&parenParam='+parentesco+'&tienePacId='+tienePacId);
  //abrir_ventana('../planmedico/print_pm_clientes_list.jsp?appendFilter='+appendFilter+'&tipo=<%=tipo%>');
}
function printEC(){
  if (getCurClientId() != "") {
		var k=document.result.index.value;
		var clientName=clientId=eval('document.result.clientName'+k).value;
		var num_cont_resp=clientId=eval('document.result.num_cont_resp'+k).value;
		var contratos=clientId=eval('document.result.contratos'+k).value;
		//if(num_cont_resp>0) 
		abrir_ventana('../planmedico/print_estado_cuenta.jsp?clientId='+getCurClientId()+'&clientName='+clientName+'&contrato='+contratos);
		//else alert('El estado de cuenta es solo para clientes Responsables de Contratos!.');
	}	
  
}
function printExcel(){
  if (getCurClientId() != "") {
		var k=document.result.index.value;
		var clientName=clientId=eval('document.result.clientName'+k).value;
		var num_cont_resp=clientId=eval('document.result.num_cont_resp'+k).value;
		var contratos=clientId=eval('document.result.contratos'+k).value;
		//if(num_cont_resp>0) 
			abrir_ventana('../planmedico/rpt_print_estado_cuenta.jsp?codigo='+getCurClientId()+'&clientName='+clientName+'&contrato='+contratos);
		//else alert('El estado de cuenta es solo para clientes Responsables de Contratos!.');
	}	
  
}
function setIndex(k){document.result.index.value=k;checkOne('result','check',<%=al.size()%>,eval('document.result.check'+k),0);
document.getElementById("cClientId").value=eval('document.result.clientId'+k).value;}
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
	else if(option==0)abrir_ventana('../planmedico/pm_cliente_config.jsp?fp=pm_cliente');
	else
	{
		if(k=='')alert('Por favor seleccione un cliente antes de ejecutar una acción!');
		else
		{
			var msg='';
			var dob=eval('document.result.dob'+k).value;
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
		case 0:msg='Crear Nuevo Cliente';break;
		case 1:msg='Editar Cliente'+(getCurClientId()!=""?" #"+getCurClientId():"");break;
		case 2:msg='Imprimir Listado'+(getCurClientId()!=""?" #"+getCurClientId():"");break;
		case 3:msg='Ver Cliente'+(getCurClientId()!=""?" #"+getCurClientId():"");break;
		case 4:msg='Imprimir Estado de Cuenta'+(getCurClientId()!=""?" #"+getCurClientId():"");break;
		case 5:msg='Asignar PAC_ID' +(getCurClientId()!=""?" #"+getCurClientId():"");break;
		case 6:msg='Imprimir Estado de Cuenta Excel'+(getCurClientId()!=""?" #"+getCurClientId():"");break;
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

function getCurClientId(){return document.getElementById("cClientId").value;}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLAN MEDICO - CLIENTES - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<%if(!fp.equals("admision")){%>
<tr>
	<td align="right">
		<div id="optDesc" class="TextInfo Text10">&nbsp;</div>
		<authtype type='3'><a href="javascript:goOption(0)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,0)" onMouseOut="javascript:mouseOut(this,0)" src="../images/add_client.png"></a></authtype>
		<authtype type='4'><a href="javascript:goOption(1)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/edit_client.png"></a></authtype>
		
		<authtype type='1'><a href="javascript:goOption(3)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/ver.png"></a></authtype>
		<authtype type='0'><a href="javascript:printList()"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" src="../images/printer.png"  onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" ></a></authtype>
		<authtype type='50'><a href="javascript:printEC()"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" src="../images/imprimir_analisis.png"  onMouseOver="javascript:mouseOver(this,4)" onMouseOut="javascript:mouseOut(this,4)" ></a></authtype>
		<authtype type='51'><a href="javascript:goOption(5)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" src="../images/actualizar.gif"  onMouseOver="javascript:mouseOver(this,5)" onMouseOut="javascript:mouseOut(this,5)" ></a></authtype>
		<authtype type='53'><a href="javascript:printExcel()"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" src="../images/imprimir_analisis.png"  onMouseOver="javascript:mouseOver(this,4)" onMouseOut="javascript:mouseOut(this,4)" ></a></authtype>
		
	</td>
</tr>
<%}%>
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextFilter">
		<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("fp",fp)%>
			<td width="8%">
				<cellbytelabel id="1">Pac. Id./<br>Sin Pac. Id.</cellbytelabel><br>
				<%=fb.intBox("clientId","",false,false,false,5,10,"Text10",null,null)%>/<%=fb.checkbox("tienePacId","S",(tienePacId.equals("S")),false,null,null,"")%>
			</td>
			<td width="10%">
				<cellbytelabel id="2">Fecha Nac.</cellbytelabel><br>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="dob" />
				<jsp:param name="valueOfTBox1" value="<%=dob%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				<jsp:param name="clearOption" value="true" />
				</jsp:include>
			</td>
			<td width="5%">
				<cellbytelabel id="3">C&oacute;digo</cellbytelabel><br>
				<%=fb.intBox("codigo","",false,false,false,5,5,"Text10",null,null)%>
			</td>
			<td width="5%">
				<cellbytelabel id="3">Contrato</cellbytelabel><br>
				<%=fb.intBox("contrato",contrato,false,false,false,10,20,"Text10",null,null)%>
			</td>
			<td width="16%">
				<cellbytelabel id="4">Nombre</cellbytelabel><br>
				<%=fb.textBox("nombre","",false,false,false,30,"Text10",null,"")%>
			</td>
			<td width="15%">
				<cellbytelabel id="5">Apellido</cellbytelabel><br>
				<%=fb.textBox("apellido","",false,false,false,30,"Text10",null,null)%>
			</td>
			<td width="14%" align="left" valign="top">
				<cellbytelabel id="7">C&eacute;dula / Pasaporte</cellbytelabel><br>
				<%=fb.textBox("cedulaPasaporte",cedulaPasaporte,false,false,false,20,"Text10",null,null)%>
			</td>
			<td width="6%">
				<cellbytelabel id="8">Estado</cellbytelabel><br>
				<%=fb.select("status","A=ACTIVO,I=INACTIVO",status,false,false,0,"Text10",null,null,null,"T")%>
			</td>
			<td width="7%">
				<cellbytelabel id="9">Tipo Clte.</cellbytelabel><br>
				<%=fb.select("tipo_clte","S=SOLICITANTE,C=CLIENTE",tipo_clte,false,false,0,"Text10",null,null,null,"T")%>
			</td>
			<td width="10%">
				<cellbytelabel id="9">Parentesco:</cellbytelabel><br>
				<%=fb.select(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn from tbl_pla_parentesco where disponible_en_pm = 'S' order by 1","parentesco",parentesco,false,false,0,"Text10",null,null,null,"S")%>
			</td>
			<td width="15%">
				<cellbytelabel id="10">Tipo</cellbytelabel><br>
				<%if(fp.equals("admision")){%>
				<%=fb.select("tipo","B=BENEFICIARIO",tipo,false,false,0,"Text10",null,null,null,"")%>
				<%} else {%>
				<%=fb.select("tipo","B=BENEFICIARIO,R=RESPONSABLE",tipo,false,false,0,"Text10",null,null,null,"T")%>
				<%}%>
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
<%=fb.hidden("clientId",clientId)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("vip",vip)%>
<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("tipo_clte",tipo_clte)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("parentesco",parentesco)%>
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
<%=fb.hidden("clientId",clientId)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("vip",vip)%>
<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("huella",huella)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("tipo_clte",tipo_clte)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("parentesco",parentesco)%>
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
			<td width="5%"><cellbytelabel id="3">Pac Id.</cellbytelabel></td><!---->
			<td width="7%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
			<td width="8%"><cellbytelabel id="2">Fecha Nac.</cellbytelabel></td>
			<td width="13%"><cellbytelabel id="7">C&eacute;dula / Pasaporte</cellbytelabel></td>
			<td width="18%"><cellbytelabel id="4">Nombre</cellbytelabel></td>
			<td width="23%"><cellbytelabel id="5">Apellido</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="13">Sexo</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="14">Contrato</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="15">Formulario</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="15">Cuotas Iniciales</cellbytelabel></td>
			<td width="5%"><cellbytelabel id="8">Estado</cellbytelabel></td>
			<td width="5%"><cellbytelabel id="8">Cont. E.C.</cellbytelabel></td>
			<%if(!fp.equals("admision")){%><td width="6%">&nbsp;</td><%}%>
		</tr>
<%fb = new FormBean("result",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("index","")%>
<%=fb.hidden("cClientId","")%>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("clientId"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("dob"+i,cdo.getColValue("fecha_nacimiento"))%>
		<%=fb.hidden("codClie"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("status"+i,cdo.getColValue("estatus"))%>
		<%=fb.hidden("showFac"+i,cdo.getColValue("showFac"))%>
		<%=fb.hidden("num_cont_resp"+i,cdo.getColValue("num_cont_resp"))%>
		<%=fb.hidden("clientName"+i,cdo.getColValue("nombre")+" "+cdo.getColValue("apellido"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("pac_id")%></td><!---->
			<td align="center"><%=cdo.getColValue("codigo")%></td>
			<td align="center"><%=cdo.getColValue("fecha_nacimiento")%></td>
			<td><%=cdo.getColValue("cedulaPasaporte")%></td>
			<td><%=cdo.getColValue("nombre")%></td>
			<td><%=cdo.getColValue("apellido")%></td>
			<td align="center"><%=(cdo.getColValue("sexo").equalsIgnoreCase("F"))?"FEMENINO":"MASCULINO"%></td>
			<td align="center">
			<authtype type='51'>
			<%
			 StringTokenizer st = new StringTokenizer(cdo.getColValue("contrato"), ",");
			 String cont = "", numero ="";
			 int c=0;
			 while (st.hasMoreTokens()) {
				 cont = st.nextToken();
				 numero = cont.substring(0, cont.indexOf("-"));
				if(c==0){
				%>
				<a class="Link00Bold" href="javascript:showForm(<%=numero%>, <%=cdo.getColValue("codigo")%>, 'C')"><%=(c>0?", ":"")%><%=cont%></a>
				<%
				} else {
				%>
				<%=(c>0?", ":"")%><%=cont%>
				<%	
				}
				c++;
			 }
			%>
			</authtype>
			</td>
			<td align="center">
			<authtype type='52'>
			<%
			 st = new StringTokenizer(cdo.getColValue("contrato"), ",");
			 cont = ""; 
			 numero ="";
			 c=0;
			 while (st.hasMoreTokens()) {
				 cont = st.nextToken();
				 numero = cont.substring(0, cont.indexOf("-"));
				 if(c==0){
				%>
				<a class="Link05Bold" href="javascript:showForm(<%=numero%>, <%=cdo.getColValue("codigo")%>, 'F')"><%=(c>0?", ":"")%><%=cont%></a>
				<%
				} else {
				%>
				<%=(c>0?", ":"")%><%=cont%>
				<%	
				}
				c++;
			 }
			%>
			</authtype>
			</td>
			<td align="center"><%st = new StringTokenizer(cdo.getColValue("cuotas_iniciales"), ",");
			 cont = ""; 
			 numero ="";
			 c=0;
			 while (st.hasMoreTokens()) {
				 cont = st.nextToken();
				 numero = cont.substring(0, cont.indexOf("="));
				%>
				<%=(c>0?", ":"")%><%=cont%>
				<%
				c++;
			 }
			%></td>
			<td align="center"><%=(cdo.getColValue("estatus").equalsIgnoreCase("A"))?"ACTIVO":"INACTIVO"%></td>
			<td align="center">
			<%
			 st = new StringTokenizer(cdo.getColValue("contrato"), ",");
			 cont = ""; 
			 numero ="";
			 String select_contrato = "";
			 c=0;
			 while (st.hasMoreTokens()) {
				 cont = st.nextToken();
				 numero = cont.substring(0, cont.indexOf("-"));
				 if(c>0) select_contrato += ", ";
				 select_contrato += numero + "=" + numero;
				c++;
			 }
			%>
			<%=fb.select("contratos"+i,select_contrato,"",false,false,0,"Text10",null,null,null,"")%>
			</td>

			<%if(!fp.equals("admision")){%>
			<td align="center"><%=fb.checkbox("check"+i,"",false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%></td>
			<%}%>
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
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("vip",vip)%>
<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("huella",huella)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("tipo_clte",tipo_clte)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("parentesco",parentesco)%>
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
<%=fb.hidden("clientId",clientId)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("vip",vip)%>
<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("huella",huella)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("tipo_clte",tipo_clte)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("parentesco",parentesco)%>
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