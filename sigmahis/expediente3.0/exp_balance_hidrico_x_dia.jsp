<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.expediente.BalanceHidrico"%>
<%@ page import="issi.expediente.DetalleBalance"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2"/>
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="LAdmin" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="LElim" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="BHMgr" scope="session" class="issi.expediente.BalanceHidricoMgr"/>
<jsp:useBean id="iBalance" scope="session" class="java.util.Hashtable"/>
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
BHMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
BalanceHidrico balance = new BalanceHidrico();
CommonDataObject cdo = new CommonDataObject();
String active0 = "", active1 = "";

boolean viewMode = false;
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String tab = request.getParameter("tab");
String change = request.getParameter("change");
String sql = "";
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fecha_eval = request.getParameter("fecha_eval");
String desc = request.getParameter("desc");
String amPm = request.getParameter("am_pm");
String codigo = request.getParameter("codigo");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String filter = "", op="", appendFilter = "";
int size = 0;
int LElimLastLineNo = 0;
int LAdminLastLineNo = 0;
int balLastLineNo = 0;

if (desc == null) desc = "";
if (amPm == null) amPm = "AM";
if (codigo == null) codigo = "0";

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (tab == null) tab = "0";
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (request.getParameter("LAdminLastLineNo") != null) LAdminLastLineNo = Integer.parseInt(request.getParameter("LAdminLastLineNo"));
if (request.getParameter("LElimLastLineNo") != null) LElimLastLineNo = Integer.parseInt(request.getParameter("LElimLastLineNo"));

if (tab.equals("0")) active0 = "active";
else if (tab.equals("1")) active1 = "active";

if (request.getMethod().equalsIgnoreCase("GET")) {
	if (fecha_eval != null) {
		filter = fecha_eval;
		if (fecha_eval.equals(cDateTime.substring(0,10))) {
			modeSec="edit";
			if (!viewMode) viewMode = false;
		}
	} else filter = cDateTime.substring(0,10);
	
	String ojoin =  "(+)", tipoLiquido = "I"; 
	if (tab.equals("1")) tipoLiquido = "E"; 

	cdo = SQLMgr.getData("SELECT a.codigo, to_char(a.fecha,'dd/mm/yyyy') fecha, a.observacion FROM TBL_SAL_BALANCE_hidrico a WHERE a.pac_id = "+pacId+" and a.secuencia = "+noAdmision+" AND to_char(a.FECHA,'dd/mm/yyyy') = '"+filter+"' AND EXISTS (SELECT NULL FROM TBL_SAL_DETALLE_BALANCE b WHERE b.PAC_ID = a.PAC_ID AND b.ADM_SECUENCIA = a.SECUENCIA AND b.COD_BALANCE = a.CODIGO AND b.VIA_ADMINISTRACION IN (SELECT CODIGO FROM tbl_sal_via_admin WHERE TIPO_LIQUIDO = '"+tipoLiquido+"' AND STATUS = 'A'))");
	if (cdo == null) cdo = new CommonDataObject();
	
	sql = "select observacion, to_char(a.fecha,'dd/mm/yyyy') as fecha,nvl(b.ingreso,0)ingreso,nvl(b.egreso,0)egreso, nvl(decode(sign(b.balance),1,'+'||b.balance,''||b.balance),0) as balance from tbl_sal_balance_hidrico a, (select z.pac_id, z.adm_secuencia, z.fecha, sum(decode(y.tipo_liquido,'I',z.cantidad,'E',-1*z.cantidad,0)) as balance , sum(decode(y.tipo_liquido,'I',z.cantidad,0))ingreso,sum(decode(y.tipo_liquido,'E',z.cantidad,0))egreso from tbl_sal_detalle_balance z, tbl_sal_via_admin y where z.pac_id="+pacId+" and z.adm_secuencia="+noAdmision+" and z.via_administracion=y.codigo group by z.pac_id, z.adm_secuencia, z.fecha) b where a.pac_id="+pacId+" and a.secuencia="+noAdmision+" and a.pac_id=b.pac_id and a.secuencia=b.adm_secuencia and a.fecha=b.fecha order by a.fecha desc";
	al2 = SQLMgr.getDataList(sql);
	
	String sequence = "'00' as \"00\",'01' as \"01\",'02' as \"02\",'03' as \"03\",'04' as \"04\",'05' as \"05\",'06' as \"06\",'07' as \"07\",'08' as \"08\",'09' as \"09\",'10' as \"10\",'11' as \"11\"";
	if (amPm.equalsIgnoreCase("PM")) sequence = "'12' as \"12\",'13' as \"13\",'14' as \"14\",'15' as \"15\",'16' as \"16\",'17' as \"17\",'18' as \"18\",'19' as \"19\",'20' as \"20\",'21' as \"21\",'22' as \"22\",'23' as \"23\"";
		
	if (!cdo.getColValue("codigo", " ").trim().equals("")) {
		if (!viewMode) {
			modeSec = "edit";
		}
		
		ojoin = "";
		codigo = cdo.getColValue("codigo");
	}
	
	if (viewMode) ojoin = "";
	
	al = SQLMgr.getDataList("select * from (SELECT to_char(b.fecha,'dd/mm/yyyy') as fecha, b.cod_balance as codBalance, nvl(b.via_administracion,v.codigo) as viaAdministracion,to_char(b.hora,'hh24') as horaC, b.fluido as fluido,b.peso as peso, b.cantidad as cantidad, b.unidad as unidad, b.tiempo_elim as tiempoelim, /*b.observacion as observacion,*/ b.seleccionar as seleccionar, v.descripcion as descripcion, v.tipo_liquido as tipoLiquido, b.via_admin_med viaAdminMed FROM TBL_SAL_DETALLE_BALANCE b ,tbl_sal_via_admin v where b.pac_id"+ojoin+" = "+pacId+" and b.adm_secuencia"+ojoin+" = "+noAdmision+" and b.via_administracion"+ojoin+" = v.codigo and v.TIPO_LIQUIDO in('"+tipoLiquido+"') AND v.status = 'A' and trunc(fecha"+ojoin+") = to_date('"+filter+"','dd/mm/yyyy') order by to_date(to_char(b.fecha,'dd/mm/yyyy')||' '||to_char(b.hora,'hh24:mi:ss'),'dd/mm/yyyy hh24:mi:ss')) pivot (max(cantidad) for horaC in ("+sequence+") ) order by viaadministracion");
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script>
var noNewHeight = true;
document.title = 'EXPEDIENTE - Balance Hidrico - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function addVia(bal,tab){abrir_ventana1('../expediente/via_admin_list.jsp?fp=balHidrico&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&LElimLastLineNo<%=LElimLastLineNo%>&LAdminLastLineNo<%=LAdminLastLineNo%>&bal='+bal+'&tab='+tab);}
function verControl(k){
	var fecha_e=eval('document.listado.fecha_evaluacion'+k).value;
	var modeSec='view';if(fecha_e=='<%=cDateTime.substring(0,10)%>')modeSec='edit';
	window.location='../expediente3.0/exp_balance_hidrico_x_dia.jsp?&modeSec='+modeSec+'&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&tab=<%=tab%>&am_pm=<%=amPm%>&fecha_eval='+fecha_e;
}
function getHorario(ddl){var selVal=ddl.options[ddl.selectedIndex].value;if(selVal=='todos'){document.getElementById('rangoFecha').style.display='';}else{document.getElementById('rangoFecha').style.display='none';}return selVal;}
var xHeight=0;
function doAction(){checkViewMode();}

function addOM(i) {
  abrir_ventana1('../expediente/exp_list_medicamento.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&exp=3&index='+i);
}

function rangoFechaCtrl(action){
    $("#rangoFecha input").each(function(i,el){
       var $el = $(el);
	   if (action == "E") {
         $("#rangoFecha").show();
	     $el.prop("readonly",false);
	     $el.prop("disabled",false);
	     $("#reset"+$el.attr('id')).prop("disabled",false);
	   }
	   else if(action == "D") {
         $("#rangoFecha").hide();
	     $el.prop("readonly",true).val("");
	     $el.prop("disabled",true).val(""); 
         $("#reset"+$el.attr('id')).prop("disabled",true);
	   }
	});
}

function imprimir(){
    var horario = "todos";
    var fecha = document.form0.balFechaIn.value;
    var from = document.listado.from.value;
    var to = document.listado.to.value;
    if (!from || !to) parent.CBMSG.error("Por favor ingresar un rango de fecha!");
    else abrir_ventana1('../expediente/print_balance_hidrico.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha='+fecha+'&desc=<%=desc%>&horario='+horario+'&from='+from+'&to='+to);
}
function imprimirChart(){
    var horario = "todos";
    var fecha = document.form0.balFechaIn.value;
    var from = document.listado.from.value;
    var to = document.listado.to.value;
    if (!from || !to) parent.CBMSG.error("Por favor ingresar un rango de fecha!");
    else abrir_ventana1('../expediente/print_balance_hidrico_chart.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha='+fecha+'&desc=<%=desc%>&horario='+horario+'&from='+from+'&to='+to);
}
function imprimirBalanceDet(){var fecha=document.form0.balFechaIn.value;abrir_ventana1('../expediente/print_balance_hidrico_ingresos_egresos.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&fecha='+fecha);}

function imprimirXHora(rptType){
    var fecha = document.form0.balFechaIn.value;
    abrir_ventana1('../cellbyteWV/report_container.jsp?reportName=expediente/rpt_balance_hidrico.rptdesign&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha='+fecha+'&tipo_desc=<%=desc%>&pCtrlHeader=false&rptType='+rptType);
}

$(function() {
	$(".balFechaIn, .balFechaOut").css({width: 100})
	
	$(".am-pm").click(function() {
		window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&tab=<%=tab%>&modeSec=<%=modeSec%>&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&LElimLastLineNo=<%=LElimLastLineNo%>&LAdminLastLineNo=<%=LAdminLastLineNo%>&desc=<%=request.getParameter("desc")%>&fecha_eval=<%=filter%>&am_pm='+this.value;
	});
	
	$(".switcher").click(function() {
		var self = $(this);
		var type = self.data('type');
		var tab = type == 'E' ? '1' : '0';
		
		window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&am_pm=<%=amPm%>&modeSec=<%=modeSec%>&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha_eval=<%=filter%>&LElimLastLineNo=<%=LElimLastLineNo%>&LAdminLastLineNo=<%=LAdminLastLineNo%>&desc=<%=request.getParameter("desc")%>&tab='+tab;
	});
});

function add () {
	var fechaEval = $("#balFechaIn", "#form0").val();
	<%if(tab.equals("1")){%>
		var fechaEval = $("#balFechaOut", "#form1").val();
	<%}%>
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&tab=<%=tab%>&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&LElimLastLineNo=<%=LElimLastLineNo%>&LAdminLastLineNo=<%=LAdminLastLineNo%>&desc=<%=request.getParameter("desc")%>&modeSec=add&am_pm=<%=amPm%>&fecha_eval='+fechaEval;
}

function verHistorial() {
  $("#hist_container").toggle();
}

function validQTY() {	
	for (i = 1; i<=<%=al.size()%>; i++) {
		<%if(amPm.equalsIgnoreCase("PM")){%>
			for (j = 12; j <=23; j++) {
		<%} else {%>
			for (j = 0; j <=11; j++) {
		<%}%>
		    var $el = $("#cantidad_"+i+"_"+j, "#form<%=tab%>");
			var qty = $.trim($el.val());
		    if (qty) {
				var parts = qty.split("/");
				
				if (parts.length != 2) {
					alert("Por favor indique la cantidad/fluido");
					$el.get(0).focus()
					return false;
				}
				
				if (!$.trim(parts[0]) || isNaN(parts[0])) {
					alert("La cantidad debe ser numérica");
					$el.get(0).focus()
					return false;
				}
				
				if (!$.trim(parts[1])) {
					alert("Por favor indique la cantidad/fluido");
					$el.get(0).focus()
					return false;
				}
			}		
		}
	}
	
	return true;
}
</script>
</head>
<body class="body-form" onLoad="javascript:doAction()">
<div class="row">
<div class="table-responsive" data-pattern="priority-columns">

<div class="headerform">
<%fb = new FormBean2("listado",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("desc",desc)%>
<table cellspacing="0" class="table pull-right table-striped table-custom-2">
	<tr>
        <td class="controls form-inline">

            <!--
			<button type="button" name="imprimir-bal" id="imprimir-bal" class="btn btn-inverse btn-sm" onclick="javascript:imprimirBalanceDet()"><i class="fa fa-eye fa-lg"></i> Ver Balance</button>
            
            <cellbytelabel id="4">Horario</cellbytelabel>: <%//=fb.select("horario","todos=TODOS,_24h=ULTIMAS 24/H,turnoActual=TURNO ACTUAL","",false,false,0,"form-control input-sm",null,"",null," ")%>
            
            <span style="text-align:right;" id="rangoFecha">
                <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="2"/>
                <jsp:param name="nameOfTBox1" value="from"/>
                <jsp:param name="valueOfTBox1" value="<%=cDateTime.substring(0,10)%>"/>
                <jsp:param name="nameOfTBox2" value="to"/>
                <jsp:param name="valueOfTBox2" value="<%=cDateTime.substring(0,10)%>"/>
                <jsp:param name="clearOption" value="true"/>
                </jsp:include>
            </span>

            <button type="button" name="imprimir-eval" id="imprimir-eval" class="btn btn-inverse btn-sm" onclick="javascript:imprimir()"><i class="fa fa-print fa-lg"></i> Imprimir Evaluaci&oacute;n</button>
            
            <button type="button" name="imprimir-chart" id="imprimir-chart" class="btn btn-inverse btn-sm" onclick="javascript:imprimirChart()"><i class="fa fa-print fa-lg"></i> Imprimir Gr&aacute;fica</button>
            
            <button type="button" name="imprimir-xhour" id="imprimir-xhour" class="btn btn-inverse btn-sm" onclick="javascript:imprimirXHora('D')"><i class="fa fa-print fa-lg"></i> x Hora</button>
            
            <button type="button" name="imprimir-xhourshift" id="imprimir-xhourshift" class="btn btn-inverse btn-sm" onclick="javascript:imprimirXHora('T')"><i class="fa fa-print fa-lg"></i> x Hora Turno</button>
			-->
			<%if(!mode.trim().equalsIgnoreCase("view") && !modeSec.trim().equalsIgnoreCase("add")){%>
				<button type="button" class="btn btn-inverse btn-sm" onClick="add()">
					<i class="fa fa-plus fa-printico"></i> <b>Agregar</b>
				  </button>
			 <%}%>
 
			<%if(al2.size() > 0){%>
				<button type="button" class="btn btn-inverse btn-sm" onClick="verHistorial()">
					<i class="fa fa-eye fa-printico"></i> <b>Historial</b>
				</button>
		  <%}%>
     
        </td>
   </tr>
</table>
    
    <div class="table-wrapper" id="hist_container" style="display:none">
       <table cellspacing="0" class="table table-small-font table-bordered table-striped">
        <tr class="bg-headtabla">
            <td width="15%"><cellbytelabel id="8">Fecha</cellbytelabel></td>
            <td width="25%"><cellbytelabel id="9">Observaci&oacute;n</cellbytelabel></td>
            <td width="10%"><cellbytelabel id="10">Admin</cellbytelabel>.</td>
            <td width="10%"><cellbytelabel id="11">Elim</cellbytelabel>.</td>
            <td width="10%"><cellbytelabel id="12">Balance</cellbytelabel></td>
            <td width="15%"><cellbytelabel id="13"></cellbytelabel></td>
            <td width="15%">&nbsp;</td>
        </tr>
        <%if(appendFilter.equals("1") && !op.trim().equals("0")){%>
        <%=fb.hidden("fecha_evaluacion0",cDateTime.substring(0,10))%>
        <tr class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')" style="cursor:pointer" onClick="javascript:verControl(0)" >
            <td><%=cDateTime.substring(0,10)%></td>
            <td><cellbytelabel id="14">Evaluaci&oacute;n Actual</cellbytelabel></td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
        </tr>
		<%}
        for (int i=1; i<=al2.size(); i++){
            CommonDataObject cdo2 = (CommonDataObject) al2.get(i-1);
            %>
            <%=fb.hidden("fecha_evaluacion"+i,cdo2.getColValue("fecha"))%>
            <tr class="pointer" onClick="javascript:verControl(<%=i%>)" >
                <td><%=cdo2.getColValue("fecha")%></td>
                <td><%=cdo2.getColValue("observacion")%></td>
                <td><%=cdo2.getColValue("ingreso")%></td>
                <td><%=cdo2.getColValue("egreso")%></td>
                <td><%=cdo2.getColValue("balance")%></td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
            </tr>
         <%}%>

</table>
    </div>
<%=fb.formEnd(true)%>
</div>

<div>

  <!-- Nav tabs -->
  <ul class="nav nav-tabs" role="tablist">
    <li role="presentation" class="<%=active0%>">
        <a href="#liq_admin" aria-controls="liq_admin" role="tab" data-toggle="tab" data-type="I" class="switcher"><b>Liquidos Administrados</b></a>
    </li>
    <li role="presentation" class="<%=active1%>">
        <a href="#liq_elim" aria-controls="liq_elim" role="tab" data-toggle="tab" data-type="E" class="switcher"><b>Liquidos Eliminados</b></a>
    </li>
  </ul>

  <!-- Tab panes -->
  <div class="tab-content">
  
    <div role="tabpanel" class="tab-pane <%=active0%>" id="liq_admin">
    <%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
    <%=fb.formStart(true)%>
    <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
    <%=fb.hidden("baction","")%>
    <%=fb.hidden("mode",mode)%>
    <%=fb.hidden("modeSec",modeSec)%>
    <%=fb.hidden("seccion",seccion)%>
    <%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
    <%=fb.hidden("dob","")%>
    <%=fb.hidden("codPac","1")%>
    <%=fb.hidden("pacId",pacId)%>
    <%=fb.hidden("noAdmision",noAdmision)%>
    <%=fb.hidden("adminSize",""+LAdmin.size())%>
    <%=fb.hidden("elimSize",""+LElim.size())%>
    <%=fb.hidden("LAdminLastLineNo",""+LAdminLastLineNo)%>
    <%=fb.hidden("LElimLastLineNo",""+LElimLastLineNo)%>
    <%=fb.hidden("tab","0")%>
    <%=fb.hidden("codigo", codigo)%>
    <%=fb.hidden("tipoPersonal",balance.getTipoPersonal())%>
    <%=fb.hidden("personalG",balance.getPersonalG())%>
    <%=fb.hidden("empProvincia",balance.getEmpProvincia())%>
    <%=fb.hidden("empSigla",balance.getEmpSigla())%>
    <%=fb.hidden("empTomo",balance.getEmpTomo())%>
    <%=fb.hidden("empAsiento",balance.getEmpAsiento())%>
    <%=fb.hidden("empCompania",balance.getEmpCompania())%>
    <%=fb.hidden("personal",balance.getPersonal())%>
    <%=fb.hidden("usuarioCreacion",balance.getUsuarioCreacion())%>
    <%=fb.hidden("fechaCreacion",balance.getFechaCreacion())%>
    <%=fb.hidden("usuarioModificacion",balance.getUsuarioModificacion())%>
    <%=fb.hidden("fechaModificacion",balance.getFechaModificacion())%>
    <%=fb.hidden("empId",balance.getEmpId())%>
    <%=fb.hidden("desc",desc)%>
    <%=fb.hidden("fecha_eval", filter)%>
    <%=fb.hidden("size", ""+al.size())%>
       
        <table cellspacing="0" class="table table-small-font table-bordered">
            <tr>
                <td colspan="4" class="controls form-inline">
				   <div class="row">
					   <div class="col-md-3">
							<cellbytelabel id="8">Fecha</cellbytelabel>
							<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1"/>
							<jsp:param name="clearOption" value="true"/>
							<jsp:param name="nameOfTBox1" value="balFechaIn"/>
							<jsp:param name="valueOfTBox1" value="<%=filter%>"/>
							<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
							<jsp:param name="fieldClass" value="balFechaIn"/>
							</jsp:include>&nbsp;&nbsp;
							
							<label class="form-check-label" for="am">
								<input class="form-check-input am-pm" type="radio" name="am_pm" id="am" value="AM"<%=amPm.equalsIgnoreCase("AM")?" checked" : ""%>> AM
							</label>&nbsp;
							<label class="form-check-label" for="pm">
								<input class="form-check-input am-pm" type="radio" name="am_pm" id="pm" value="PM"<%=amPm.equalsIgnoreCase("PM")?" checked" : ""%>> PM
							</label>
					   </div>
				   
					   <div class="col-md-9">
						   <div class="row">
								<% 
								if (amPm.equalsIgnoreCase("PM")) {
									for (int j = 12; j <=23; j++){%>
										<div class="col-sm-1">
											<label class="i-ampm-lbl" id="i-lbl-<%=j%>"><%=j<10?"0"+j:j%></label>
										</div>	
									<%}%>
								<%} else {
									for (int j = 0; j <=11; j++){%>
										<div class="col-sm-1">
											<label class="i-ampm-lbl" id="i-lbl-<%=j%>"><%=j<10?"0"+j:j%></label>
										</div>	
								<%}}%>
						   </div>
					   </div>
                   </div>
                </td>
            </tr>
            <%
                for (int i = 1; i <= al.size(); i++){
					
                CommonDataObject newBalance = (CommonDataObject) al.get(i-1);
                boolean readOnly = viewMode || (newBalance.getColValue("viaAdministracion") != null && !newBalance.getColValue("viaAdministracion").equals(""));
            %>
            <%=fb.hidden("fechaDetalle"+i,newBalance.getColValue("fecha"))%>
            <%=fb.hidden("key"+i, newBalance.getKey())%>
            <%=fb.hidden("remove"+i,"")%>
            <%=fb.hidden("codBalance"+i,newBalance.getColValue("codBalance"))%>
            <%=fb.hidden("codigobal"+i,newBalance.getColValue("codigo"))%>
            <%=fb.hidden("seleccionar"+i,newBalance.getColValue("seleccionar"))%>
            <%=fb.hidden("via_admin_med"+i,newBalance.getColValue("viaAdminMed"))%>
            <%=fb.hidden("idAdmin"+i,newBalance.getColValue("viaAdministracion"))%>
			
			<tr>
				<td colspan="4">
					<div class="row">
						<div class="col-md-3">
							<%=newBalance.getColValue("descripcion")%>
						</div>

						<div class="col-md-9 controls form-inline pull-center">
							<div class="row">
								<% 
								if (amPm.equalsIgnoreCase("PM")) {
									for (int j = 12; j < 24; j++){%>
										<div class="col-sm-1">
											<div class="form-group">
											  <%=fb.textBox("cantidad_"+i+"_"+j, newBalance.getColValue(""+j) ,false,false,viewMode,4, 0, "form-control input-sm qty", "", "", "Cantidad/Fluido", false, " placeholder='Qty/Fluido'")%>
											  <%=fb.hidden("am_pm_hour_"+i+"_"+j, ""+j)%>
											  <%=fb.hidden("am_pm_hour_value_"+i+"_"+j, newBalance.getColValue(""+j))%>
											</div>
										</div>	
									<%}%>
								<%} else {
									for (int j = 0; j < 12; j++){%>
										<div class="col-sm-1">
											<div class="form-group">
											  <%=fb.textBox("cantidad_"+i+"_"+j, newBalance.getColValue((j<10 ? "0"+j : ""+j)),false,false,viewMode,4,0, "form-control input-sm qty", "", "", "Cantidad/Fluido", false, " placeholder='Qty/Fluido'")%>
											  <%=fb.hidden("am_pm_hour_"+i+"_"+j, (j<10 ? "0"+j : ""+j))%>
											  <%=fb.hidden("am_pm_hour_value_"+i+"_"+j, newBalance.getColValue((j<10 ? "0"+j : ""+j)))%>
											</div>
										</div>	
								<%}}%>
							</div>
						</div>
					</div>
				</td>			
			</tr>
			
            <%}//for %>
			
			<tr>
				<td colspan="4">
					<%=fb.textarea("observacion",cdo.getColValue("observacion"),false,false,viewMode,50,0,2000,"form-control input-sm","width:100%",null)%>
				</td>
			</tr>
        </table>
        
        <div class="footerform" style="bottom:0 !important; margin-top: 20px">
            <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
                <tr>
                    <td><small>Opciones de Guardar: <label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
                    <%=fb.submit("save","Guardar",true,viewMode,"btn btn-inverse btn-sm",null,"")%>
                    <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
                </tr>
            </table>   
            </div>
			
	    <%fb.appendJsValidation("if(!validQTY()){error++;}");%>		
        <%=fb.formEnd(true)%>
        </div>
		
        <div role="tabpanel" class="tab-pane <%=active1%>" id="liq_elim">
		
		<%fb = new FormBean2("form1",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
		<%=fb.formStart(true)%>
		<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
		<%=fb.hidden("baction","")%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("modeSec",modeSec)%>
		<%=fb.hidden("seccion",seccion)%>
		<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
		<%=fb.hidden("dob","")%>
		<%=fb.hidden("codPac","")%>
		<%=fb.hidden("pacId",pacId)%>
		<%=fb.hidden("noAdmision",noAdmision)%>
		<%=fb.hidden("adminSize",""+LAdmin.size())%>
		<%=fb.hidden("elimSize",""+LElim.size())%>
		<%=fb.hidden("LAdminLastLineNo",""+LAdminLastLineNo)%>
		<%=fb.hidden("LElimLastLineNo",""+LElimLastLineNo)%>
		<%=fb.hidden("tab","1")%>
		<%=fb.hidden("codigo", codigo)%>
		<%=fb.hidden("tipoPersonal",balance.getTipoPersonal())%>
		<%=fb.hidden("personalG",balance.getPersonalG())%>
		<%=fb.hidden("empProvincia",balance.getEmpProvincia())%>
		<%=fb.hidden("empSigla",balance.getEmpSigla())%>
		<%=fb.hidden("empTomo",balance.getEmpTomo())%>
		<%=fb.hidden("empAsiento",balance.getEmpAsiento())%>
		<%=fb.hidden("empCompania",balance.getEmpCompania())%>
		<%=fb.hidden("personal",balance.getPersonal())%>
		<%=fb.hidden("usuarioCreacion",balance.getUsuarioCreacion())%>
		<%=fb.hidden("fechaCreacion",balance.getFechaCreacion())%>
		<%=fb.hidden("usuarioModificacion",balance.getUsuarioModificacion())%>
		<%=fb.hidden("fechaModificacion",balance.getFechaModificacion())%>
		<%=fb.hidden("empId",balance.getEmpId())%>
		<%=fb.hidden("desc",desc)%>
		<%=fb.hidden("size", ""+al.size())%>
		<%=fb.hidden("fecha_eval", filter)%>
		
		 <table cellspacing="0" class="table table-small-font table-bordered">
            <tr>
                <td colspan="4" class="controls form-inline">
				   <div class="row">
					   <div class="col-md-3">
							<cellbytelabel id="8">Fecha</cellbytelabel>
							<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1"/>
							<jsp:param name="clearOption" value="true"/>
							<jsp:param name="nameOfTBox1" value="balFechaOut"/>
							<jsp:param name="valueOfTBox1" value="<%=filter%>"/>
							<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
							<jsp:param name="fieldClass" value="balFechaOut"/>
							</jsp:include>&nbsp;&nbsp;
							
							<label class="form-check-label" for="am">
								<input class="form-check-input am-pm" type="radio" name="am_pm" id="am" value="AM"<%=amPm.equalsIgnoreCase("AM")?" checked" : ""%>> AM
							</label>&nbsp;
							<label class="form-check-label" for="pm">
								<input class="form-check-input am-pm" type="radio" name="am_pm" id="pm" value="PM"<%=amPm.equalsIgnoreCase("PM")?" checked" : ""%>> PM
							</label>
					   </div>
				   
					   <div class="col-md-9">
						   <div class="row">
								<% 
								if (amPm.equalsIgnoreCase("PM")) {
									for (int j = 12; j <=23; j++){%>
										<div class="col-sm-1">
											<label class="i-ampm-lbl" id="i-lbl-<%=j%>"><%=j<10?"0"+j:j%></label>
										</div>	
									<%}%>
								<%} else {
									for (int j = 0; j <=11; j++){%>
										<div class="col-sm-1">
											<label class="i-ampm-lbl" id="i-lbl-<%=j%>"><%=j<10?"0"+j:j%></label>
										</div>	
								<%}}%>
						   </div>
					   </div>
                   </div>
                </td>
            </tr>
            <%
                for (int i = 1; i <= al.size(); i++){
					
                CommonDataObject newBalance = (CommonDataObject) al.get(i-1);
                boolean readOnly = viewMode || (newBalance.getColValue("viaAdministracion") != null && !newBalance.getColValue("viaAdministracion").equals(""));
            %>
            <%=fb.hidden("fechaDetalle"+i,newBalance.getColValue("fecha"))%>
            <%=fb.hidden("key"+i, newBalance.getKey())%>
            <%=fb.hidden("remove"+i,"")%>
            <%=fb.hidden("codBalance"+i,newBalance.getColValue("codBalance"))%>
            <%=fb.hidden("codigobal"+i,newBalance.getColValue("codigo"))%>
            <%=fb.hidden("seleccionar"+i,newBalance.getColValue("seleccionar"))%>
            <%=fb.hidden("via_admin_med"+i,newBalance.getColValue("viaAdminMed"))%>
            <%=fb.hidden("idAdmin"+i,newBalance.getColValue("viaAdministracion"))%>
			
			<tr>
				<td colspan="4">
					<div class="row">
						<div class="col-md-3">
							<%=newBalance.getColValue("descripcion")%>
						</div>

						<div class="col-md-9 controls form-inline pull-center">
							<div class="row">
								<% 
								if (amPm.equalsIgnoreCase("PM")) {
									for (int j = 12; j < 24; j++){%>
										<div class="col-sm-1">
											<div class="form-group">
											  <%=fb.textBox("cantidad_"+i+"_"+j, newBalance.getColValue(""+j) ,false,false,viewMode,4, 0,"form-control input-sm qty", "", "", "Cantidad/Fluido", false, " placeholder='Qty/Fluido'")%>
											  <%=fb.hidden("am_pm_hour_"+i+"_"+j, ""+j)%>
											  <%=fb.hidden("am_pm_hour_value_"+i+"_"+j, newBalance.getColValue(""+j))%>
											</div>
										</div>	
									<%}%>
								<%} else {
									for (int j = 0; j < 12; j++){%>
										<div class="col-sm-1">
											<div class="form-group">
											  <%=fb.textBox("cantidad_"+i+"_"+j, newBalance.getColValue((j<10 ? "0"+j : ""+j)),false,false,viewMode,4, 0,"form-control input-sm qty", "", "", "Cantidad/Fluido", false, " placeholder='Qty/Fluido'")%>
											  <%=fb.hidden("am_pm_hour_"+i+"_"+j, (j<10 ? "0"+j : ""+j))%>
											  <%=fb.hidden("am_pm_hour_value_"+i+"_"+j, newBalance.getColValue((j<10 ? "0"+j : ""+j)))%>
											</div>
										</div>	
								<%}}%>
							</div>
						</div>
					</div>
				</td>			
			</tr>
			
            <%}//for %>
			
			<tr>
				<td colspan="4">
					<%=fb.textarea("observacion",cdo.getColValue("observacion"),false,false,viewMode,50,0,2000,"form-control input-sm","width:100%",null)%>
				</td>
			</tr>
			
			<tr>
              <td>
                <div class="footerform" style="bottom:0 !important">
                <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
                    <tr>
                        <td><small>Opciones de Guardar: <label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
                        <%=fb.submit("save","Guardar",true,viewMode,"btn btn-inverse btn-sm",null,"")%>
                        <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
                    </tr>
                </table>   
            </div>
              </td>
            </tr>
			<%fb.appendJsValidation("if(!validQTY()){error++;}");%>	
        <%=fb.formEnd(true)%>
        </table>
        
		
        </div>
    
  </div> <!-- Tab panes -->

</div>

</div>
</div>
</body>
</html>
<%
}//GET
else
{

	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

	if (tab.equals("0")) //Liquidos administrados
	{
		al.clear();
		int sizeAdmin = 0;
		if (request.getParameter("size") != null) sizeAdmin = Integer.parseInt(request.getParameter("size"));
		String itemRemoved = "";
		
		cdo = new CommonDataObject();
		cdo.setTableName("tbl_sal_balance_hidrico");
		boolean headerEdited = false;
						
		if (modeSec.equalsIgnoreCase("add")) {
			CommonDataObject cdoNext = SQLMgr.getData("select nvl(max(codigo),0) + 1 as codigo from TBL_SAL_BALANCE_HIDRICO where pac_id = "+request.getParameter("pacId")+" and secuencia = "+request.getParameter("noAdmision"));
			codigo = cdoNext.getColValue("codigo");
			
			cdo.addColValue("codigo", codigo);
			
			cdo.addColValue("secuencia", request.getParameter("noAdmision"));
			cdo.addColValue("pac_id", request.getParameter("pacId"));
			cdo.addColValue("cod_paciente", request.getParameter("codPac"));
			cdo.addColValue("fec_nacimiento", request.getParameter("dob"));
			cdo.addColValue("emp_compania", (String) session.getAttribute("_companyId"));
			cdo.addColValue("personal", "E");
			
			cdo.addColValue("usuario_creacion", UserDet.getUserName());
			cdo.addColValue("fecha_creacion", cDateTime);
			cdo.setAction("I");
		} else {
			cdo.setWhereClause(" pac_id = "+request.getParameter("pacId")+" and secuencia = "+request.getParameter("noAdmision")+" and trunc(fecha) = to_date('"+request.getParameter("balFechaIn")+"','dd/mm/yyyy')");
			
			cdo.addColValue("usuario_modificacion", UserDet.getUserName());
			cdo.addColValue("fecha_modificacion", cDateTime);
			cdo.setAction("U");
			headerEdited = true;
		}
		
		cdo.addColValue("fecha", request.getParameter("balFechaIn"));
		cdo.addColValue("observacion", request.getParameter("observacion"));
		
		int start = 0;
		int total = 11;
		
		if (amPm.equalsIgnoreCase("PM")) {
		   start = 12;
		   total = 23;
		}

		for (int i=1; i<= sizeAdmin; i++) {
			for (int j = 0; j <= 23; j++){
			    CommonDataObject cdo2 = new CommonDataObject();
			    cdo2.setTableName("tbl_sal_detalle_balance"); 

				String qty = "", observacion = "", hour = (j<10 ? "0"+j+":00:00" : j+":00:00");
				try {
					String[] qtyParts = request.getParameter("cantidad_"+i+"_"+j).split("/");
					qty = qtyParts[0];
					observacion = qtyParts[1];
				} catch(Exception e) {}
									
				if(!"".equals(qty)) cdo2.addColValue("cantidad", qty);
				if(!"".equals(observacion)) cdo2.addColValue("observacion", observacion);
				cdo2.addColValue("hora", hour);

				if (modeSec.equalsIgnoreCase("edit")) {
					cdo2.setAction("U");
					cdo2.setWhereClause("to_char(fecha,'dd/mm/yyyy') = '"+request.getParameter("balFechaIn")+"' and cod_balance = "+codigo+" and pac_id="+request.getParameter("pacId")+" and adm_secuencia = "+request.getParameter("noAdmision")+" and to_char(hora,'hh24:mi:ss') = '"+hour+"' and via_administracion = "+request.getParameter("idAdmin"+i));
					
					//cdo2.addColValue("hora", request.getParameter("am_pm_hour_"+i+"_"+j)+":00:00");
				} else {
					cdo2.setAction("I");
					cdo2.addColValue("fecha", request.getParameter("balFechaIn"));
					cdo2.addColValue("cod_balance", codigo);
					cdo2.addColValue("adm_secuencia", request.getParameter("noAdmision"));
					cdo2.addColValue("fecha_nacimiento", request.getParameter("dob"));
					cdo2.addColValue("codigo_paciente", request.getParameter("codPac"));
					cdo2.addColValue("via_administracion", request.getParameter("idAdmin"+i));
					
					cdo2.addColValue("codigo", "(select nvl(max(codigo),0) + 1 as codigo from TBL_SAL_DETALLE_BALANCE where pac_id="+request.getParameter("pacId")+"and adm_secuencia="+request.getParameter("noAdmision")+"AND cod_balance ="+codigo+")");
					cdo2.addColValue("seleccionar", "S");
					cdo2.addColValue("pac_id", request.getParameter("pacId"));
				}
				
			    al.add(cdo2);	
			}
		}

		if (baction.equalsIgnoreCase("Guardar")) {
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			SQLMgr.save(cdo, al, true ,true, true, true);
			ConMgr.clearAppCtx(null);
		}

	}
	
	if (tab.equals("1")) //Liquido  Eliminados
	{
		al.clear();
		int sizeAdmin = 0;
		if (request.getParameter("size") != null) sizeAdmin = Integer.parseInt(request.getParameter("size"));
		String itemRemoved = "";
		
		cdo = new CommonDataObject();
		cdo.setTableName("tbl_sal_balance_hidrico");
		boolean headerEdited = false;
						
		if (modeSec.equalsIgnoreCase("add")) {
			CommonDataObject cdoNext = SQLMgr.getData("select nvl(max(codigo),0) + 1 as codigo from TBL_SAL_BALANCE_HIDRICO where pac_id = "+request.getParameter("pacId")+" and secuencia = "+request.getParameter("noAdmision"));
			codigo = cdoNext.getColValue("codigo");
			
			cdo.addColValue("codigo", codigo);
			
			cdo.addColValue("secuencia", request.getParameter("noAdmision"));
			cdo.addColValue("pac_id", request.getParameter("pacId"));
			cdo.addColValue("cod_paciente", request.getParameter("codPac"));
			cdo.addColValue("fec_nacimiento", request.getParameter("dob"));
			cdo.addColValue("emp_compania", (String) session.getAttribute("_companyId"));
			cdo.addColValue("personal", "E");
			
			cdo.addColValue("usuario_creacion", UserDet.getUserName());
			cdo.addColValue("fecha_creacion", cDateTime);
			cdo.setAction("I");
		} else {
			cdo.setWhereClause(" pac_id = "+request.getParameter("pacId")+" and secuencia = "+request.getParameter("noAdmision")+" and trunc(fecha) = to_date('"+request.getParameter("balFechaOut")+"','dd/mm/yyyy')");
			
			cdo.addColValue("usuario_modificacion", UserDet.getUserName());
			cdo.addColValue("fecha_modificacion", cDateTime);
			cdo.setAction("U");
			headerEdited = true;
		}
		
		cdo.addColValue("fecha", request.getParameter("balFechaOut"));
		cdo.addColValue("observacion", request.getParameter("observacion"));
		
		int start = 0;
		int total = 11;
		
		if (amPm.equalsIgnoreCase("PM")) {
		   start = 12;
		   total = 23;
		}
		boolean forceInsert = false;
		
		if (headerEdited && codigo.equals("0")) {
			CommonDataObject cdoC = SQLMgr.getData("SELECT a.codigo FROM TBL_SAL_BALANCE_hidrico a WHERE a.pac_id = "+pacId+" and a.secuencia = "+noAdmision+" AND to_char(a.FECHA,'dd/mm/yyyy') = '"+request.getParameter("balFechaOut")+"'");
			codigo = cdoC.getColValue("codigo");
			
			forceInsert = true;
		}

		for (int i=1; i<= sizeAdmin; i++) {
			for (int j = 0; j <=23; j++){
			    CommonDataObject cdo2 = new CommonDataObject();
			    cdo2.setTableName("tbl_sal_detalle_balance"); 

				String qty = "", observacion = "", hour = (j<10 ? "0"+j+":00:00" : j+":00:00");
				try {
					String[] qtyParts = request.getParameter("cantidad_"+i+"_"+j).split("/");
					qty = qtyParts[0];
					observacion = qtyParts[1];
				} catch(Exception e) {}
									
				cdo2.addColValue("hora", hour);				
				if(!"".equals(qty)) cdo2.addColValue("cantidad", qty);
				if(!"".equals(observacion)) cdo2.addColValue("observacion", observacion);
				
				if (modeSec.equalsIgnoreCase("edit") && !codigo.equals("0") && !forceInsert) {
					cdo2.setAction("U");
					cdo2.setWhereClause("to_char(fecha,'dd/mm/yyyy') = '"+request.getParameter("balFechaOut")+"' and cod_balance = "+codigo+" and pac_id="+request.getParameter("pacId")+" and adm_secuencia = "+request.getParameter("noAdmision")+" and to_char(hora,'hh24:mi:ss') = '"+hour+"' and via_administracion = "+request.getParameter("idAdmin"+i));
				} else {
					cdo2.setAction("I");
					cdo2.addColValue("fecha", request.getParameter("balFechaOut"));
					cdo2.addColValue("cod_balance", codigo);
					cdo2.addColValue("adm_secuencia", request.getParameter("noAdmision"));
					cdo2.addColValue("fecha_nacimiento", request.getParameter("dob"));
					cdo2.addColValue("codigo_paciente", request.getParameter("codPac"));
					cdo2.addColValue("via_administracion", request.getParameter("idAdmin"+i));
					
					cdo2.addColValue("codigo", "(select nvl(max(codigo),0) + 1 as codigo from TBL_SAL_DETALLE_BALANCE where pac_id="+request.getParameter("pacId")+"and adm_secuencia="+request.getParameter("noAdmision")+"AND cod_balance ="+codigo+")");
					cdo2.addColValue("seleccionar", "S");
					cdo2.addColValue("pac_id", request.getParameter("pacId"));
				}
				
			    al.add(cdo2);	
			}
		}

		if (baction.equalsIgnoreCase("Guardar")) {
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			SQLMgr.save(cdo, al, true ,true, true, true);
			ConMgr.clearAppCtx(null);
		}
	}

%>
<html>
<head>

<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_redirect.jsp"))
	{
%>
window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_redirect.jsp")%>';
<%
	}
	else
	{
%>
//window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_redirect.jsp';
<%
	}

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
parent.doRedirect(0);
<%
}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&tab=<%=tab%>&modeSec=add&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&LElimLastLineNo=<%=LElimLastLineNo%>&LAdminLastLineNo=<%=LAdminLastLineNo%>&desc=<%=request.getParameter("desc")%>&modeSec=<%=modeSec%>&am_pm=<%=amPm%>&fecha_eval=<%=request.getParameter("fecha_eval")%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&tab=<%=tab%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&LElimLastLineNo=<%=LElimLastLineNo%>&LAdminLastLineNo=<%=LAdminLastLineNo%>&desc=<%=request.getParameter("desc")%>&am_pm=<%=amPm%>&fecha_eval=<%=request.getParameter("fecha_eval")%>';
}
</script>

</head>
<body onLoad="closeWindow()" class="TextRow01">
</body>
</html>
<%
}
%>

