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
ADM60096
==================================================================================
**/
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
String pacId = request.getParameter("pacId");
String dob = request.getParameter("dob");
String codigo = request.getParameter("codigo");
String nombre = request.getParameter("nombre");
String apellido = request.getParameter("apellido");
String vip = request.getParameter("vip");
String cedulaPasaporte = request.getParameter("cedulaPasaporte");
String status = request.getParameter("status");
String huella = request.getParameter("huella");
int iconHeight = 36;
int iconWidth = 36;
String fp = request.getParameter("fp");

if (fp == null) fp = "";
if (pacId == null) pacId = "";
if (dob == null) dob = "";//CmnMgr.getCurrentDate("dd/mm/yyyy");
if (codigo == null) codigo = "";
if (nombre == null) nombre = "";
if (apellido == null) apellido = "";
if (vip == null) vip = "";
if (cedulaPasaporte == null) cedulaPasaporte = "";
if (status == null) status = "";
if (huella == null) huella = "";

if (!pacId.trim().equals("")) { sbFilter.append(" and pac_id="); sbFilter.append(pacId); }
if (!dob.trim().equals("")) { sbFilter.append(" and to_char(f_nac,'dd/mm/yyyy')='"); sbFilter.append(dob); sbFilter.append("'"); }
if (!codigo.trim().equals("")) { sbFilter.append(" and codigo="); sbFilter.append(codigo); }
if (!nombre.trim().equals("")) { sbFilter.append(" and upper(primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
if (!apellido.trim().equals("")) { sbFilter.append(" and upper(primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' DE '||apellido_de_casada))) like '%"); sbFilter.append(apellido.toUpperCase()); sbFilter.append("%'"); }
if (!vip.trim().equals("")) { sbFilter.append(" and upper(vip)='"); sbFilter.append(vip.toUpperCase()); sbFilter.append("'"); }
if (!cedulaPasaporte.trim().equals("")) { sbFilter.append(" and upper(coalesce(pasaporte,provincia||'-'||sigla||'-'||tomo||'-'||asiento)||'-'||d_cedula) like '%"); sbFilter.append(cedulaPasaporte.toUpperCase()); sbFilter.append("%'"); }

if (status.trim().equals("Z")){
  sbFilter.append(" and excluido = 'S'");
}else {
    if (!status.trim().equals("")) { sbFilter.append(" and estatus = '"); sbFilter.append(status); sbFilter.append("'"); }
}

if (!huella.trim().equals("") && huella.trim().equals("S")) { sbFilter.append("  and pac_id in (select owner_id from tbl_bio_fingerprint where capture_type = 'PAC') ");}
else if (!huella.trim().equals("") && huella.trim().equals("N")) { sbFilter.append("  and pac_id not in (select owner_id from tbl_bio_fingerprint where capture_type = 'PAC') ");}
else sbFilter.append(" ");

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

	if(request.getParameter("pacId")!= null){
	sbSql.append("select pac_id, to_char(fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, codigo, id_paciente as cedulaPasaporte, primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre) as nombre, primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' DE '||apellido_de_casada)) as apellido, sexo, estatus, decode(VIP,'S','VIP','N','NORMAL','D','DISTINGUIDO','M','MEDICO STAFF','J','J.DIRECTIVA') as pFidelizacion, pasaporte, provincia, sigla, tomo, asiento, d_cedula, nvl(get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'TP_CLIENTE_PAC'),-1)tp_cli_pac,to_char(f_nac,'dd/mm/yyyy') as f_nac, excluido");
	if (isFpEnabled) sbSql.append(", (select count(*) from tbl_bio_fingerprint where owner_id = pac_id and capture_type = 'PAC') as fpOwner");
	sbSql.append(" from vw_adm_paciente where pac_id is not null");
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
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/autocomplete_header.jsp"%>

<script language="javascript">
document.title = 'Paciente - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function printList(){abrir_ventana('../admision/print_list_paciente.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>');}
function setIndex(k){document.result.index.value=k;checkOne('result','check',<%=al.size()%>,eval('document.result.check'+k),0);}

function createAdm(status, pacId) {
    if(status !='I'){
        if(pacId!=''){
            var retVal = getDBData('<%=request.getContextPath()%>','nvl(getDeuda(<%=(String) session.getAttribute("_companyId")%>,\'PAC\','+pacId+'),\'0|0\')','dual','','');
            var deuda =parseFloat(retVal.substring(retVal.indexOf('|')+1));	
            var nFactura = retVal.substring(0,retVal.indexOf('|'));
            
            if (deuda > 0){
                
                CBMSG.confirm('El Paciente tiene '+nFactura+' facturas, con saldo pendientes que ascienden a '+deuda.toFixed(2)+'\n'+'El paciente tiene deuda pendiente con la Clínica, ¿Desea continuar con la admisión bajo su responsabilidad?',{opacity:.2,btnTxt:'Si,No',cb:function(r){
                              if (r=="Si")abrir_ventana('../admision/admision_config_new.jsp?mode=add&pacId='+pacId);
                              //else CBMSG.error('Acción Cancelada!');
                            }});	
            }
            else abrir_ventana('../admision/admision_config_new.jsp?mode=add&pacId='+pacId);
        }
    }else CBMSG.warning('No se puede crear admisiones a pacientes Inactivos!!!');
}

function goOption(option){
	var k=document.result.index.value;
	var pacId='';
	var status ='';
		if(k!='')
		{
			pacId=eval('document.result.pacId'+k).value;
			status=eval('document.result.status'+k).value;
		}
	if(option==undefined)CBMSG.warning('La opción no está definida todavía.\nPor favor consulte con su Administrador!');
	else if(option==0)abrir_ventana('../admision/paciente_config.jsp');
	else if(option==10) abrir_ventana("../cellbyteWV/report_container.jsp?reportName=admision/rpt_pac_con_huella.rptdesign");
	else if(option==2)
	{
		var excluido = document.querySelector("#excluido"+k) ? document.querySelector("#excluido"+k).value : 'N';
        if (excluido == "S") {
          CBMSG.warning('"NO EXISTE DISPONIBILIDAD DE CAMAS. CONSULTAR CON SU SUPERVISOR"', {
           opacity:1,
           btnTxt: "Ok",
           cb: function(r) {
             if (r == 'Ok') { 
               createAdm(status, pacId);
             }
           }
           });
        } else createAdm(status, pacId);
	}
	else
	{
		if(k=='')CBMSG.warning('Por favor seleccione un paciente antes de ejecutar una acción!');
		else
		{
			var msg='';
			var dob=eval('document.result.dob'+k).value;
			var codPac=eval('document.result.codPac'+k).value;

			if(option==1)abrir_ventana('../admision/paciente_config.jsp?mode=edit&pacId='+pacId+"&tipo=ADM");
			else if(option==3)abrir_ventana('../expediente/print_list_ordenmedica.jsp?pacId='+pacId);
			else if(option==4)abrir_ventana('../expediente/expediente_config.jsp?fp=paciente&pacId='+pacId);
			else if(option==5)abrir_ventana('../admision/paciente_config.jsp?mode=view&pacId='+pacId);
			else if(option==6)abrir_ventana('../admision/editar_fecha_nac.jsp?id='+pacId);
			else if(option==7)abrir_ventana('../admision/merge_paciente.jsp?pacId='+pacId);
			else if(option==8)abrir_ventana('../admision/reemplazar_pac_id.jsp?id='+pacId);
			else if(option==11)showPopWin('../process/upd_fidelizacion_pac.jsp?id='+pacId,winWidth*.75,winHeight*.65,null,null,'');
			else if(option==9) {
				 var hasHuella = getDBData('<%=request.getContextPath()%>','count(*)','tbl_bio_fingerprint h','h.owner_id='+pacId+' and capture_type=\'PAC\'','');
				 if(parseInt(hasHuella) > 0){
						 showPopWin('../common/run_process.jsp?fp=patient_list&actType=10&docType=FP_PAC&docId='+pacId+'&docNo='+pacId,winWidth*.75,winHeight*.65,null,null,'');
				 }else{CBMSG.warning("No pudimos encontrar la Huella de este paciente << "+pacId+" >> ");}
			}
		}//admision selected
	}//valid option
}

<!-- W I N D O W S -->
//Windows Size and Position
var _winWidth=screen.availWidth*0.35;
var _winHeight=screen.availHeight*0.35;
var _winPosX=(screen.availWidth-_winWidth)/2;
var _winPosY=(screen.availHeight-_winHeight)/2;
var _popUpOptions='toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width='+_winWidth+',height='+_winHeight+',top='+_winPosY+',left='+_winPosX;
function printRFP(pac_id,refType)
{
	var val = '../common/sel_periodo.jsp?fg=PAC&pac_id='+pac_id+'&refId='+pac_id+'&refType='+refType+'&referTo=PAC';
	window.open(val,'datesWindow',_popUpOptions);
	//abrir_ventana('../facturacion/print_estado_cargo_res.jsp?pacId='+pacId+'&fDate=01/01/2000&tDate=01/01/2009');
}

function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 0:msg='Crear Nuevo Paciente';break;
		case 1:msg='Editar Paciente';break;
		case 2:msg='Crear Nueva Admisión';break;
		case 3:msg='Lista de Ordenes Médicas';break;
		case 4:msg='Expediente Histórico';break;
		case 5:msg='Ver Detalles del Paciente';break;
		case 6:msg='Modificar Fecha de Nacimiento';break;
		case 7:msg='Merge Paciente';break;
		case 8:msg='Reemplazar Codigo de Paciente';break;
		case 9:msg='Remover Huella Dactilar';break;
		case 10:msg='Imprimir Pacientes con Huella (Excel)';break;
		case 11:msg='Actualizar Programa de Fidelizacion';break;
		default:msg='&nbsp;';
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

function pendingBalanceConfirmation(k)
{
	var proceed = true;
	var pacId = document.result.pacId.value;
	var noAdmision = document.form0.noAdmision.value;
	var retVal = '';
	var facturadoA = 'P';
	if (noAdmision != 0 && hasBeneficioEmpleado()) facturadoA = 'E';
    
	var retVal = getDBData('<%=request.getContextPath()%>','nvl(getDeuda(<%=(String) session.getAttribute("_companyId")%>,\'PAC\','+pacId+'),\'0|0\')','dual','','');
	deuda =parseFloat(retVal.substring(retVal.indexOf('|')+1));	
    var nFactura = retVal.substring(0,retVal.indexOf('|'));

	if (deuda > 0)
	{
		proceed = confirm('El Paciente tiene '+nFactura+' facturas pendientes que ascienden a '+deuda.toFixed(2)+'\n'+'El paciente tiene deuda pendiente con la Clínica, ¿Desea continuar con la admisión bajo su responsabilidad?');
		if (proceed) eval('document.form'+tab+'.proceedPendingBalance').value = 'Y';
		else eval('document.form'+tab+'.proceedPendingBalance').value = 'N';
	}
	else eval('document.form'+tab+'.proceedPendingBalance').value = '';

	return proceed;
}

function doSearch(el){
	 var elForm = document.getElementById(el);
	 elForm.submit();
}

$(function() {
  $("#go").click(function(e){
    
    if ( !$.trim($("#pacId").val()) && !$.trim($("#dob").val())  && !$.trim($("#codigo").val())  && !$.trim($("#nombre").val())  && !$.trim($("#apellido").val()) && !$.trim($("#cedulaPasaporte").val()) && !$("#vip").val() && !$("#huella").val() && !$("#status").val() ) {
      alert("Por favor subministre por lo menos un filtro.");
    } else $("#search00").submit()
    
  });
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CLINICA - ADMISION - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right">
		<div id="optDesc" class="TextInfo Text10">&nbsp;</div>
		<%if(!fp.equals("exp")){%>
		<% if (isFpEnabled) { %><authtype type='57'><a href="javascript:goOption(9)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,9)" onMouseOut="javascript:mouseOut(this,9)" src="../images/fingerprint-remove.png"></a></authtype><% } %>
		<authtype type='3'><a href="javascript:goOption(0)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,0)" onMouseOut="javascript:mouseOut(this,0)" src="../images/patient.gif"></a></authtype>
		<authtype type='4'><a href="javascript:goOption(1)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/patient_config.gif"></a></authtype>
		<authtype type='1'><a href="javascript:goOption(5)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,5)" onMouseOut="javascript:mouseOut(this,5)" src="../images/search.gif"></a></authtype>
		<authtype type='50'><a href="javascript:goOption(2)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/case.jpg"></a></authtype>
		<authtype type='51'><a href="javascript:goOption(3)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/medic_notes.gif"></a></authtype>
		<authtype type='52'><a href="javascript:goOption(4)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,4)" onMouseOut="javascript:mouseOut(this,4)" src="../images/open-folder.jpg"></a></authtype>
		<authtype type='53'><a href="javascript:goOption(6)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,6)" onMouseOut="javascript:mouseOut(this,6)" src="../images/actualizar.jpg"></a></authtype>
		<authtype type='56'><a href="javascript:goOption(10)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,10)" onMouseOut="javascript:mouseOut(this,10)" src="../images/printer_fp.gif"></a></authtype>
		<authtype type='57'><a href="javascript:goOption(11)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,11)" onMouseOut="javascript:mouseOut(this,11)" src="../images/cambio_de_estado_admision.png"></a></authtype> 
		<%} else {%>
		<authtype type='54'><a href="javascript:goOption(7)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,7)" onMouseOut="javascript:mouseOut(this,7)" src="../images/user_group.gif"></a></authtype>
		<authtype type='55'><a href="javascript:goOption(8)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,8)" onMouseOut="javascript:mouseOut(this,8)" src="../images/switch_user.gif"></a></authtype>
		<%}%>
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
			<td width="5%">
				<cellbytelabel id="1">ID</cellbytelabel><br>
				<%=fb.intBox("pacId","",false,false,false,5,10,"Text10",null,null)%>
			</td>
			<td width="10%">
				<cellbytelabel id="2">Fecha Nac.</cellbytelabel><br>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="nameOfTBox1" value="dob"/>
				<jsp:param name="valueOfTBox1" value="<%=dob%>"/>
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
				<jsp:param name="clearOption" value="true"/>
				</jsp:include>
			</td>
			<td width="5%">
				<cellbytelabel id="3">C&oacute;digo</cellbytelabel><br>
				<%=fb.intBox("codigo","",false,false,false,5,5,"Text10",null,null)%>
			</td>
			<td width="16%">
				<cellbytelabel id="4">Nombre</cellbytelabel><br>
				<%=fb.textBox("nombre","",false,false,false,30,"Text10",null,"")%>
			</td><!--containerCollapseEvent-->

			<td width="15%">
				<cellbytelabel id="5">Apellido</cellbytelabel><br>
				<%=fb.textBox("apellido","",false,false,false,30,"Text10",null,null)%>
			</td>
			<td width="10%">
				<cellbytelabel id="6">P.Fidelización</cellbytelabel><br>
				<%//=fb.select("vip","N=NORMAL,S=VIP,D=DISTINGUIDO,M=MEDICO STAFF,J=J.DIRECTIVA",vip,false,false,0,"Text10",null,null,null,"T")%>
				<%=fb.select(ConMgr.getConnection(),"select vip as code, descripcion FROM tbl_adm_tipo_paciente order by id","vip",vip,false,false,0,"text10","","","","T")%>
			</td>
			<td width="14%" align="left">
				<cellbytelabel id="7">C&eacute;dula / Pasaporte</cellbytelabel><br>
				<%//=fb.textBox("cedulaPasaporte",cedulaPasaporte,false,false,false,20,"Text10",null,null)%>
				<%String sQueryString = "";%>
			<jsp:include page="../common/autocomplete.jsp" flush="false">
					<jsp:param name="fieldId" value="cedulaPasaporte"/>
					<jsp:param name="fieldValue" value="<%=cedulaPasaporte%>"/>
					<jsp:param name="fieldIsRequired" value="n"/>
					<jsp:param name="fieldIsReadOnly" value="n"/>
					<jsp:param name="fieldClass" value="Text10"/>
					<jsp:param name="containerSize" value="150%"/>
					<jsp:param name="maxDisplay" value="20"/>
					<jsp:param name="containerOnSelect" value="doSearch('search00')"/>
					<jsp:param name="dsQueryString" value="<%=sQueryString%>"/>
					<jsp:param name="dsType" value="CEDLIST"/>
				</jsp:include>
			</td>

			<td width="10%">
				&nbsp;<% if (isFpEnabled) { %>&nbsp;&nbsp;&nbsp;&nbsp;
				<cellbytelabel id="55">Huella</cellbytelabel><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<%=fb.select("huella","S=SI,N=NO",huella,false,false,0,"Text10",null,null,null,"T")%><% } %>
			</td>
			<td width="11%">
				<cellbytelabel id="8">Estado</cellbytelabel><br>
				<%=fb.select("status","A=ACTIVO,I=INACTIVO,Z=EXCLUIDO",status,false,false,0,"Text10",null,null,null,"T")%>
				<%=fb.button("go","Ir",false,false,"Text10",null,null)%>
			</td>
<%=fb.formEnd(true)%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td align="right">&nbsp;
		 <a href="javascript:printList('1')" class="Link00">[ <cellbytelabel id="9">Imprimir Lista</cellbytelabel> ]</a>
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
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("vip",vip)%>
<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("huella",huella)%>
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
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("vip",vip)%>
<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("huella",huella)%>
<%=fb.hidden("fp",fp)%>
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
<div id="_cContent" class="ContainerContent"><!---->
		<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="list" exclude="8,9">
		<tr class="TextHeader" align="center">
			<td width="7%"><cellbytelabel id="1">ID</cellbytelabel></td>
			<td width="8%"><cellbytelabel id="2">Fecha Nac.</cellbytelabel></td>
			<td width="5%"><cellbytelabel id="3">C&oacute;digo</cellbytelabel></td>
			<td width="13%"><cellbytelabel id="7">C&eacute;dula / Pasaporte</cellbytelabel></td>
			<td width="18%"><cellbytelabel id="4">Nombre</cellbytelabel></td>
			<td width="18%"><cellbytelabel id="5">Apellido</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="13">Sexo</cellbytelabel></td>
			<td width="5%"><% if (isFpEnabled) { %><cellbytelabel id="55">Huella</cellbytelabel><% } %></td>
			<td whith="10%"><cellbytelabel id="6">P.Fidelización</cellbytelabel></td>
			<td width="5%"><cellbytelabel id="8">Estado</cellbytelabel></td>
			<td width="3%">&nbsp;</td>
			<td width="3%">&nbsp;</td>
		</tr>
<%fb = new FormBean("result",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("index","")%>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("pacId"+i,cdo.getColValue("pac_id"))%>
		<%=fb.hidden("dob"+i,cdo.getColValue("fecha_nacimiento"))%>
		<%=fb.hidden("codPac"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("huella"+i,cdo.getColValue("user_id"))%>
		<%=fb.hidden("status"+i,cdo.getColValue("estatus"))%>
		<%=fb.hidden("tp_cli_pac"+i,cdo.getColValue("tp_cli_pac"))%>		
		<%=fb.hidden("excluido"+i,cdo.getColValue("excluido"))%>		
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("pac_id")%></td>
			<td align="center"><%=cdo.getColValue("f_nac")%></td>
			<td align="center"><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("cedulaPasaporte")%></td>
			<td><%=cdo.getColValue("nombre")%></td>
			<td><%=cdo.getColValue("apellido")%></td>
			<td align="center"><%=(cdo.getColValue("sexo").equalsIgnoreCase("F"))?"FEMENINO":"MASCULINO"%></td>
			<td align="center"><%if(isFpEnabled){%><img width="16" height="16" src="../images/fingerprint-<%=(cdo.getColValue("fpOwner").equals("0"))?"gray":"green"%>.png"><%}%></td>
			<td align="center"><%=cdo.getColValue("pFidelizacion")%></td>
			<td align="center"><%=(cdo.getColValue("estatus").equalsIgnoreCase("A"))?"ACTIVO":"INACTIVO"%></td>
			<td align="center"><%=fb.checkbox("check"+i,"",false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%></td>
			<td align="center"><authtype type='53'><a href="javascript:printRFP(<%=cdo.getColValue("pac_id")%>,<%=cdo.getColValue("tp_cli_pac")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel id="14">RFP</cellbytelabel></a></authtype></td>
		</tr>
<%
}
%>
		</table>
		</div>
	</div><!---->
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
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("vip",vip)%>
<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("huella",huella)%>
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
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("vip",vip)%>
<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("huella",huella)%>
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