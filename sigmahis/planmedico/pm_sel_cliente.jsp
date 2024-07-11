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
<jsp:useBean id="htClt" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vClt" scope="session" class="java.util.Vector"/>
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
String mode = request.getParameter("mode");
String cuota = request.getParameter("cuota");
String afiliados = request.getParameter("afiliados");
String en_transicion = request.getParameter("en_transicion");
int iconHeight = 32;
int iconWidth = 32;
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String tipo_clte = request.getParameter("tipo_clte");
String id_cliente = request.getParameter("id_cliente");

if (cuota == null) cuota = "";
if (afiliados == null) afiliados = "";
if (fp == null) fp = "";
if (fg == null) fg = "";
if (clientId == null) clientId = "";
if (dob == null) dob = "";//CmnMgr.getCurrentDate("dd/mm/yyyy");
if (codigo == null) codigo = "";
if (nombre == null) nombre = "";
if (apellido == null) apellido = "";
if (vip == null) vip = "";
if (cedulaPasaporte == null) cedulaPasaporte = "";
if (status == null) status = "";
if (huella == null) huella = "";
if (tipo_clte == null) tipo_clte = "";
if (mode == null) mode = "";
if (id_cliente == null) id_cliente = "";
if (en_transicion == null) en_transicion = "N";
if(tipo_clte.equals("") && fg.equalsIgnoreCase("responsable")) tipo_clte="S";

if (!clientId.trim().equals("")) { sbFilter.append(" and pac_id="); sbFilter.append(clientId); }
if (!dob.trim().equals("")) { sbFilter.append(" and to_char(fecha_nacimiento,'dd/mm/yyyy')='"); sbFilter.append(dob); sbFilter.append("'"); }
if (!codigo.trim().equals("")) { sbFilter.append(" and codigo="); sbFilter.append(codigo); }
if (!nombre.trim().equals("")) { sbFilter.append(" and upper(primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
if (!apellido.trim().equals("")) { sbFilter.append(" and upper(primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada))) like '%"); sbFilter.append(apellido.toUpperCase()); sbFilter.append("%'"); }
if (!vip.trim().equals("")) { sbFilter.append(" and upper(vip)='"); sbFilter.append(vip.toUpperCase()); sbFilter.append("'"); }
if (!cedulaPasaporte.trim().equals("")) { sbFilter.append(" and upper(coalesce(pasaporte,provincia||'-'||sigla||'-'||tomo||'-'||asiento)||'-'||d_cedula) like '%"); sbFilter.append(cedulaPasaporte.toUpperCase()); sbFilter.append("%'"); }
if (!status.trim().equals("")) { sbFilter.append(" and estatus='"); sbFilter.append(status); sbFilter.append("'"); }
if (!huella.trim().equals("") && huella.trim().equals("S")) { sbFilter.append("  and pac_id in (select owner_id from tbl_bio_fingerprint where capture_type = 'PAC') ");}
else if (!huella.trim().equals("") && huella.trim().equals("N")) { sbFilter.append("  and pac_id not in (select owner_id from tbl_bio_fingerprint where capture_type = 'PAC') ");}
else sbFilter.append(" ");
if (!tipo_clte.trim().equals("")) { sbFilter.append(" and tipo_clte='"); sbFilter.append(tipo_clte); sbFilter.append("'"); }
if(fp.equals("rep_cxc_detalle") && fg.equals("responsable")){
	sbFilter.append(" and exists (select null from tbl_pm_solicitud_contrato sc where sc.id_cliente = a.codigo and sc.estado = 'A')");
}
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
	sbSql.append("select pac_id, to_char(fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, codigo, id_paciente as cedulaPasaporte, primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre) as nombre, primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) as apellido, sexo, estatus, decode(VIP,'S','VIP','N','NORMAL','D','DISTINGUIDO','M','MEDICO STAFF','J','J.DIRECTIVA') as pFidelizacion, pasaporte, provincia, sigla, tomo, asiento, d_cedula, nvl (trunc (months_between (sysdate,coalesce (f_nac, fecha_nacimiento)-nvl((select to_number(get_sec_comp_param(-1, 'PARAM_DIAS_EDAD')) from dual), 0))/ 12),0) edad, nombre_paciente, nvl((select c.id from tbl_pm_sol_contrato_det d, tbl_pm_solicitud_contrato c where c.id = d.id_solicitud and d.id_cliente = a.codigo and c.estado in ('A','P') and d.estado != 'I' and rownum = 1), 0) contrato");
	sbSql.append(" from vw_pm_cliente a where a.estatus = 'A' ");
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
<style type="text/css">
	/* needed for stacked instances for ie & sf z-index bug of absolute inside relative els */
	#result_container {z-index:9001; color:#333; font-weight:normal;}
</style>
<script language="javascript">
document.title = 'Paciente - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,300);}
function setIndex(k){document.result.index.value=k;checkOne('result','check',<%=al.size()%>,eval('document.result.check'+k),0);}
function goOption(option){
	var k=document.result.index.value;
	var clientId='';
	var status ='';
	if(k!='')
	{
		clientId=eval('document.result.clientId'+k).value;
		status=eval('document.result.status'+k).value;
	}
	if(option==0)abrir_ventana('../planmedico/pm_cliente_config.jsp?fp=<%=fp%>&fg=<%=fg%>&id_cliente=<%=id_cliente%>');
}

<!-- W I N D O W S -->
//Windows Size and Position
var _winWidth=screen.availWidth*0.35;
var _winHeight=screen.availHeight*0.26;
var _winPosX=(screen.availWidth-_winWidth)/2;
var _winPosY=(screen.availHeight-_winHeight)/2;
var _popUpOptions='toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width='+_winWidth+',height='+_winHeight+',top='+_winPosY+',left='+_winPosX;

function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 0:msg='Crear Nuevo Cliente';break;
		case 1:msg='Editar Cliente';break;
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
function loadCliente(id, i){
	var seguir = true;
	/*
 <%if(fg.equals("responsable") && cuota.equals("SFE")){	 
		if(afiliados.equals("1")){
		%>
		if(parseInt(eval('document.result.edad'+i).value) >= 60){
			alert('La edad supera el limite para el PLAN FAMILIAR!')
			 seguir = false;
		}
		<%} else if(afiliados.equals("2")){%>
		if(parseInt(eval('document.result.edad'+i).value) < 60){
			alert('La edad no corresponde al PLAN TERCERA EDAD!')
			 seguir = false;
		}
		
		<%}%>

 <%}%>
 */
	if(seguir){
	if('<%=fp%>'=='rep_cxc_detalle'){
       var clientId = $("#clientId"+i).val();
       var clientName = $("#client_name"+i).val();
       
			 window.opener.document.form0.id_responsable.value = clientId;
			 window.opener.document.form0.responsable.value = clientName;
		
	}	else {
	window.opener.frames['clteFrame'].location = '../planmedico/cliente.jsp?id_cliente='+id;
	window.opener.frames['cuestionarioFrame'].location = '../planmedico/ver_cuestionario_cliente.jsp?id_cliente='+id;
	}
	window.close();
	}
}

function chkPlan(i){
	var en_transicion = '<%=en_transicion%>';
	<%if(cuota.equals("SFE")){%>
	if(eval('document.result.check'+i) && eval('document.result.check'+i).checked){
		<%if(afiliados.equals("1")){%>
		if(parseInt(eval('document.result.edad'+i).value) >= 60){
			alert('La edad supera el limite para el PLAN FAMILIAR!')
			 eval('document.result.check'+i).checked=false;
		}
		<%} else if(afiliados.equals("2")){%>
		if((parseInt(eval('document.result.edad'+i).value) < 60 && en_transicion == 'N') || (parseInt(eval('document.result.edad'+i).value) < 59 && en_transicion == 'S')){
			alert('La edad no corresponde al PLAN TERCERA EDAD!')
			 eval('document.result.check'+i).checked=false;
		}
		<%}%>
		if(parseInt(eval('document.result.contrato'+i).value) > 0 && en_transicion == 'N'){
			alert('El beneficiario ya esta en el contrato '+eval('document.result.contrato'+i).value);
			 eval('document.result.check'+i).checked=false;
		}
	}
	<%}%>
}


 

 
function cargarPagina(codigo){
var src = '../planmedico/pm_sel_cliente.jsp?fp=<%=fp%>&fg=<%=fg%>&cuota=<%=cuota%>&codigo='+codigo+'&clientId=&mode=<%=mode%>&afiliados=<%=afiliados%>';
window.location = src;
}

$(document).ready(function(){
   $(".setval").click(function(e){
       e.stopPropagation();
       var that = $(this);
       var i = that.data("i");
       var clientId = $("#clientId"+i).val();
       var clientName = $("#client_name"+i).val();
       
       <%if(fp.equalsIgnoreCase("rpt_miembros")){%>
         if ($("#codigo", window.opener.document).length) $("#codigo", window.opener.document).val(clientId);
         if ($("#nombre", window.opener.document).length) $("#nombre",window.opener.document).val(clientName);
         
         window.close();
       <%}%>
       
   });
});
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
		<authtype type='3'><a href="javascript:goOption(0)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,0)" onMouseOut="javascript:mouseOut(this,0)" src="../images/add_client.png"></a></authtype>
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("cuota",cuota)%>
<%=fb.hidden("afiliados",afiliados)%>
<%=fb.hidden("id_cliente",id_cliente)%>
<%=fb.hidden("en_transicion",en_transicion)%>
			<td width="5%">
				<cellbytelabel id="1">ID</cellbytelabel><br>
				<%=fb.intBox("clientId","",false,false,false,5,10,"Text10",null,null)%>
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
			<!--</td>
			<td width="16%">
				<cellbytelabel id="8">Estado</cellbytelabel><br>
				<%=fb.select("status","A=ACTIVO,I=INACTIVO",status,false,false,0,"Text10",null,null,null,"T")%>
			</td>-->
			<td width="15%">
				<cellbytelabel id="9">Tipo Clte.</cellbytelabel><br>
				<%=fb.select("tipo_clte","S=SOLICITANTE,C=CLIENTE",tipo_clte,false,false,0,"Text10",null,null,null,"")%>
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("tipo_clte",tipo_clte)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("cuota",cuota)%>
<%=fb.hidden("afiliados",afiliados)%>
<%=fb.hidden("id_cliente",id_cliente)%>
<%=fb.hidden("en_transicion",en_transicion)%>
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("tipo_clte",tipo_clte)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("cuota",cuota)%>
<%=fb.hidden("afiliados",afiliados)%>
<%=fb.hidden("id_cliente",id_cliente)%>
<%=fb.hidden("en_transicion",en_transicion)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%fb = new FormBean("result","","post","");%>
<%=fb.formStart()%>
<%=fb.hidden("index","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<tr>
	<td class="TableLeftBorder TableRightBorder">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
		<table align="center" width="100%" cellpadding="1" cellspacing="1"> <!--class="sortable" id="list" exclude="8,9"-->
		<%
		if((fp.equals("plan_medico") || fp.equals("adenda")) && fg.equals("beneficiario")){
		System.out.println("fp="+fp+"., fg="+fg+".");
		%>
		<tr class="TextHeader">
			<td align="right" colspan="9"><%=fb.submit("add","Agregar",false,false, "Text10", "", "")%></td>
		</tr>
		<%}%>
		<tr class="TextHeader" align="center">
			<td width="7%"><cellbytelabel id="1">ID</cellbytelabel></td>
			<td width="8%"><cellbytelabel id="2">Fecha Nac.</cellbytelabel></td>
			<td width="5%"><cellbytelabel id="3">C&oacute;digo</cellbytelabel></td>
			<td width="13%"><cellbytelabel id="7">C&eacute;dula / Pasaporte</cellbytelabel></td>
			<td width="23%"><cellbytelabel id="4">Nombre</cellbytelabel></td>
			<td width="28%"><cellbytelabel id="5">Apellido</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="13">Sexo</cellbytelabel></td>
			<!--<td width="5%"><cellbytelabel id="8">Estado</cellbytelabel></td>-->
			<%if((fp.equals("plan_medico") || fp.equals("adenda")) && fg.equals("beneficiario")){%><td>&nbsp;</td><%}%>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("clientId"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("fecha_nacimiento"+i,cdo.getColValue("fecha_nacimiento"))%>
		<%=fb.hidden("status"+i,cdo.getColValue("estatus"))%>
		<%=fb.hidden("client_name"+i,cdo.getColValue("nombre_paciente"))%>
		<%=fb.hidden("identificacion"+i,cdo.getColValue("cedulaPasaporte"))%>
		<%=fb.hidden("edad"+i,cdo.getColValue("edad"))%>
		<%=fb.hidden("sexo"+i,cdo.getColValue("sexo"))%>
		<%=fb.hidden("contrato"+i,cdo.getColValue("contrato"))%>
		<tr class="<%=color%> setval" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer" <%if((fp.equals("plan_medico")||fp.equals("rep_cxc_detalle")) && fg.equals("responsable")){%>onDblClick="javascript:loadCliente(<%=cdo.getColValue("codigo")%>, <%=i%>)"<%}%> data-i="<%=i%>">
			<td align="center"><%=cdo.getColValue("pac_id")%></td>
			<td align="center"><%=cdo.getColValue("fecha_nacimiento")%></td>
			<td align="center"><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("cedulaPasaporte")%></td>
			<td><%=cdo.getColValue("nombre")%></td>
			<td><%=cdo.getColValue("apellido")%></td>
			<td align="center"><%=(cdo.getColValue("sexo").equalsIgnoreCase("F"))?"FEMENINO":"MASCULINO"%></td>
			<!--<td align="center"><%=(cdo.getColValue("estatus").equalsIgnoreCase("A"))?"ACTIVO":"INACTIVO"%></td>-->
			<%if((fp.equals("plan_medico") || fp.equals("adenda")) && fg.equals("beneficiario")){%>
			<td align="center"><%//=fb.checkbox("check"+i,"",false,false,null,null,"")%>
			<%=vClt.contains(cdo.getColValue("codigo"))?"Elegido":fb.checkbox("check"+i,"",false,false,null,null,(cuota.equals("SFE")?"onClick=\"javascript:chkPlan("+i+");\"":""))%>
			</td>

			<%}%>
		</tr>
<%
}
%>
<%=fb.hidden("keySize",""+al.size())%>
		</table>
		</div>
	</div>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	</td>
</tr>
<%=fb.formEnd()%>
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("tipo_clte",tipo_clte)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("cuota",cuota)%>
<%=fb.hidden("afiliados",afiliados)%>
<%=fb.hidden("id_cliente",id_cliente)%>
<%=fb.hidden("en_transicion",en_transicion)%>
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tipo_clte",tipo_clte)%>
<%=fb.hidden("cuota",cuota)%>
<%=fb.hidden("afiliados",afiliados)%>
<%=fb.hidden("id_cliente",id_cliente)%>
<%=fb.hidden("en_transicion",en_transicion)%>
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
else
{
	System.out.println("=====================POST=====================");
	int lineNo = 0;
	lineNo = htClt.size();

	String artDel = "", key = "";;
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	if((fp.equalsIgnoreCase("plan_medico") || fp.equalsIgnoreCase("adenda")) && fg.equalsIgnoreCase("beneficiario")){
		for(int i=0;i<keySize;i++){
			CommonDataObject cd = new CommonDataObject();

			cd.addColValue("id_cliente", request.getParameter("clientId"+i));
			cd.addColValue("client_name", request.getParameter("client_name"+i));
			cd.addColValue("identificacion", request.getParameter("identificacion"+i));
			cd.addColValue("fecha_nacimiento", request.getParameter("fecha_nacimiento"+i));
			cd.addColValue("edad", request.getParameter("edad"+i));
			cd.addColValue("sexo", request.getParameter("sexo"+i));
			cd.addColValue("fecha_inicio", "");
			cd.addColValue("id", "0");
			cd.addColValue("id_solicitud", "0");


			if(request.getParameter("check"+i)!=null){

				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;

				try {
					htClt.put(key, cd);
					vClt.add(cd.getColValue("id_cliente"));
				}	catch (Exception e)	{
					System.out.println("Unable to addget item "+key);
				}

			}
		}
	}
	/*
	if(request.getParameter("addCont")!=null){
		response.sendRedirect("../common/sel_procedimiento.jsp?change=1&type=1&fg="+fg+"&fp="+fp+"&cs="+cs+"&mode="+mode);
		return;
	}
	*/

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	<%if((fp.equals("plan_medico") || fp.equals("adenda")) && fg.equals("beneficiario")){%>
	window.opener.location = '<%=request.getContextPath()+"/planmedico/reg_solicitud_det.jsp?mode="+mode+"&change=1&fg="+fg%>&fp=<%=fp%>';
	<%}%>
	window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%

}//POST
%>