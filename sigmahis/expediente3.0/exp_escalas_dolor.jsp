<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.Escalas"%>
<%@ page import="issi.expediente.DetalleEscala"%>
<%@ page import="java.util.Vector" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iMed" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="ECMgr" scope="page" class="issi.expediente.EscalaMgr" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ECMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
Escalas escala = new Escalas();
ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();
ArrayList al4 = new ArrayList();
ArrayList al5 = new ArrayList();

Vector v1 =null;
Vector v2 = null;

CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String id = request.getParameter("id");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String desc = request.getParameter("desc");
String tmpTot = request.getParameter("tmpTot")==null?"0":request.getParameter("tmpTot");
String forceSumEval = request.getParameter("forceSumEval")==null?"0":request.getParameter("forceSumEval");
int iconHeight = 48;
int iconWidth = 48;

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec == null) modeSec = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (id == null) id = "0";
if (fg == null) fg = "WB";
if (desc == null) desc = "";
if (fp == null) fp = "";
if (forceSumEval == null) forceSumEval = "";

boolean checkDefault = false;
int rowCount = 0;
String fecha = request.getParameter("fecha");
String hora_eval = request.getParameter("hora_eval");
int escLastLineNo = 0;
String appendFilter="" , op = "";
String key = "",titulo="";
String eTotal=request.getParameter("eTotal")==null?"0":request.getParameter("eTotal");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cDate = cDateTime.substring(0,10);
if (fecha == null) fecha = cDate;

if(fg.trim().equalsIgnoreCase("WB")) titulo ="ESCALA WONG BAKER ";
else if(fg.trim().equalsIgnoreCase("MO")) titulo ="ESCALA DE MORSE ";
else if(fg.trim().equalsIgnoreCase("CR")) titulo ="ESCALA CRIES";
else if(fg.trim().equalsIgnoreCase("NI")) titulo ="ESCALA NIPS";
else if(fg.trim().equalsIgnoreCase("AN")) titulo ="ESCALA ANALOGA";
else titulo ="ESCALA DE DOLOR ";

if (request.getMethod().equalsIgnoreCase("GET"))
{

sql="select to_char(se.fecha,'dd/mm/yyyy') as fecha, to_char(se.hora,'hh12:mi:ss am') as hora , se.total ,se.id,se.usuario_mod usuarioMod, to_char(se.fecha_mod,'dd/mm/yyyy')fechaMod, to_char(se.fecha_mod,'hh12:mi:ss am')horaMod,se.usuario, to_char(se.fecha_recup,'dd/mm/yyyy') fecha_recup, se.usuario_recup from tbl_sal_escalas se  where se.pac_id = "+pacId+" and se.admision = "+noAdmision+" and se.tipo ='"+fg+"' order by to_date(se.fecha||' '||to_char(se.hora,'hh12:mi:ss am'),'dd/mm/yyyy hh12:mi:ss am') desc";
al2= SQLMgr.getDataList(sql);
if(!fg.trim().equalsIgnoreCase("MO"))
{
	sql = "select codigo, descripcion from tbl_sal_dolor where estado ='A' and tipo = '"+fg+"' order by codigo";
	al3= SQLMgr.getDataList(sql);

	sql = "select codigo, descripcion from tbl_sal_intervencion_dolor where estado ='A' and tipo= 'ME' order by  tipo desc";
	al4= SQLMgr.getDataList(sql);
	sql = "select codigo, descripcion from tbl_sal_intervencion_dolor where estado ='A' and tipo= 'NF' order by  tipo desc";
	al5= SQLMgr.getDataList(sql);
}

if(!id.trim().equalsIgnoreCase("0"))
{
			sql="select to_char(fecha,'dd/mm/yyyy') as fecha, to_char(hora,'hh12:mi:ss am') as hora, observacion,total,dolor,intervencion,localizacion from tbl_sal_escalas where pac_id = "+pacId+" and admision = "+noAdmision+" and id = "+id+" and tipo ='"+fg+"'";

		escala = (Escalas) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Escalas.class);
		System.out.println("SQL = "+sql);
		if (!viewMode) modeSec = "edit";



}else //if(escala == null)
		{
				escala = new Escalas();
				escala.setHora(cDateTime.substring(11));
				escala.setFecha(cDateTime.substring(0,10));
				escala.setDolor("");
				escala.setIntervencion("");
				escala.setTotal("0");
				if (!viewMode) modeSec = "add";

		}
if(!fg.trim().equalsIgnoreCase("MO"))
{
	v1 = CmnMgr.str2vector(escala.getDolor(), java.util.regex.Pattern.quote("|"));
	v2 = CmnMgr.str2vector(escala.getIntervencion(), java.util.regex.Pattern.quote("|"));
}
//sql=" select nvl(a.codigo,0)as codigo, 0 as cod_escala,nvl(b.detalle ,0)as detalle, a.descripcion as descripcion , 0 as escala ,b.observacion, nvl(b.VALOR,0) as valor, b.APLICAR  FROM tbl_sal_concepto_norton a, ( select nvl(cod_escala ,0)as tipo_escala, nvl(detalle,0)as detalle, OBSERVACION, VALOR, APLICAR FROM tbl_sal_detalle_esc  where id ="+id+" and tipo ='"+fg+"' order by 1,2 ) b where a.codigo=b.tipo_escala(+)  and a.tipo='"+fg+"'    union SELECT a.codigo,a.secuencia, 0, a.descripcion, a.valor,null,0, '' from tbl_sal_det_concepto_norton a, ( select nvl(cod_escala,0) as tipo_escala  from tbl_sal_detalle_esc a where id = "+id+" and tipo = '"+fg+"' order by 1 ) b where  a.codigo = b.tipo_escala(+) and a.tipo ='"+fg+"' ORDER BY 1,2 ";

	sql="select nvl(a.codigo,0)as codigo, 0 as cod_escala,nvl(b.detalle ,0)as detalle, a.descripcion as descripcion , 0 as escala ,b.observacion, nvl(b.VALOR,0) as valor, b.APLICAR  FROM tbl_sal_concepto_norton a, ( select nvl(cod_escala ,0)as tipo_escala, nvl(detalle,0)as detalle, OBSERVACION, VALOR, APLICAR FROM tbl_sal_detalle_esc  where id ="+id+" and tipo = '"+fg+"' order by 1,2 ) b where a.codigo=b.tipo_escala(+)  and a.tipo='"+fg+"' and a.estado='A'  union select a.codigo,a.secuencia, 0, a.descripcion, a.valor,null,0, '' from tbl_sal_det_concepto_norton a,tbl_sal_concepto_norton c,  ( select nvl(cod_escala,0) as tipo_escala  from tbl_sal_detalle_esc a where id = "+id+" and tipo = '"+fg+"' order by 1 ) b where  a.codigo = b.tipo_escala(+) and a.tipo = '"+fg+"' and a.estado='A' and c.codigo =a.codigo(+) and a.estado(+)=c.estado ORDER BY 1,2 ";
	 al = SQLMgr.getDataList(sql);

String showRiesgo = "SIN PRECAUCION";
try{showRiesgo=java.util.ResourceBundle.getBundle("issi").getString("showRiesgo");}catch(Exception e){}
if (showRiesgo.equalsIgnoreCase("Y")) showRiesgo = "SIN RIESGO";

CommonDataObject cdoE = new CommonDataObject();

if(!id.trim().equalsIgnoreCase("0")){
		cdoE = SQLMgr.getData("select i.codigo, i.descripcion, ip.observacion from tbl_sal_intervencion i, tbl_sal_intervencion_paciente ip where i.estado = 'A' and i.tipo = '"+fg+"' and i.codigo = ip.cod_intervencion and ip.pac_id = "+pacId+" and ip.admision = "+noAdmision+" and ip.id_escala = "+id+" order by 1");

		if(cdoE == null) cdoE = new CommonDataObject();
}

/*if((fecha.trim().equals(cDate) && !id.trim().equals("0") )){
		modeSec ="edit";
		if(!mode.equalsIgnoreCase("view")) viewMode = false;
}*/
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
		<jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script>
<script>
var noNewHeight = true;
document.title = 'ESCALAS - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function verEscala(k,mode){var fecha = eval('document.form0.fecha'+k).value ;var hora = eval('document.form0.hora'+k).value ;
var cTot = eval('document.form0.total_tmp'+k).value ;
var mode ='view';
var id = eval('document.form0.code'+k).value;var tmpTot=$("#temp_total"+k).val();window.location = '../expediente3.0/exp_escalas_dolor.jsp?modeSec='+mode+'&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id='+id+'&fg=<%=fg%>&fp=<%=fp%>&desc=<%=desc%>&tmpTot='+tmpTot+'&eTotal='+cTot+'&fecha='+fecha;}
function add(){window.location = '../expediente3.0/exp_escalas_dolor.jsp?mode=<%=mode%>&modeSec=add&seccion=<%=seccion%>&pacId=<%=pacId%>&fp=<%=fp%>&noAdmision=<%=noAdmision%>&id=0&fg=<%=fg%>&desc=<%=desc%>';}
function doAction(){checkViewMode();}
function setEscalaValor(k,codigo,valor){sumaEscala();}
function distValor(j){var size1 = parseInt(document.getElementById("size").value);for (i=1;i<=size1;i++){if(i!=j)document.getElementById("escala"+i).checked = false;}eval('document.form0.opcion').value = "1";}
function setAlert(){alert('No se ha realizado la evaluación');}
function consultar(){abrir_ventana1('../expediente3.0/list_evaluacion_dolor.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&desc=<%=desc%>');}
function ayuda(){abrir_ventana1('../expediente/Escala_morse.pdf');}

function imprimir(option){
		var total = $("#total2").val() || 0;
		var intCode = "<%=cdoE.getColValue("codigo","0")%>";
		var intDesc = "<%=cdoE.getColValue("descripcion","N/A")%>";
		var intObserv = "<%=cdoE.getColValue("observacion","N/A")%>";

		if (!option)
				abrir_ventana1('../expediente3.0/print_exp_seccion_80.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=<%=modeSec%>&fg=<%=fg%>&seccion=<%=seccion%>&id=<%=id%>&desc=<%=desc%>&total='+total+'&int_code='+intCode+'&int_desc='+intDesc+'&int_observ='+intObserv);
		else
				abrir_ventana1('../expediente3.0/print_todas_las_escalas.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=<%=modeSec%>&fg=<%=fg%>&seccion=<%=seccion%>&desc=<%=desc%>');
}

function sumaEscala(val){
	var total = 0;
	for (i=1;i<=parseInt(document.getElementById("size").value);i++){
		var chk = eval('document.form0.escala'+i).length;

		if (parseInt(val,10)) total = val;
		else{
			for (k=0;k<chk;k++){
				if(eval('document.form0.escala'+i)[k].checked){
					total = total + parseInt(eval('document.form0.valorCH'+i+k).value);
					eval('document.form0.valor'+i).value = eval('document.form0.valorCH'+i+k).value;
					eval('document.form0.codDetalle'+i).value = eval('document.form0.codDetalle'+i+k).value;
				}
			}
		}
	}
	document.getElementById("total2").value = total;eval('document.form0.valIni').value = "1";
	<%if(fg.trim().equalsIgnoreCase("MO")){%>
		if (total >= 0 &&total<=24){
			document.getElementById("clasificacion").style.color='green';
			document.getElementById("clasificacion").innerHTML='<%=showRiesgo%>';
		}else if (total>=25&&total<=50){
			document.getElementById("clasificacion").style.color='orange';document.getElementById("clasificacion").innerHTML='PRECAUCION';
		}else if (total>=50){
			document.getElementById("clasificacion").style.color='red';document.getElementById("clasificacion").innerHTML='ALTO RIESGO';
		}
	<%} else if(fg.trim().equalsIgnoreCase("AN")) {%>
			if (total < 1 ) $("#clasificacion").text('SIN DOLOR').css({color: "green"})
			else if ( total >=1 && total <=2) $("#clasificacion").text('DOLOR LEVE').css({color: "orange"})
			else if ( total >= 3 && total <= 5) $("#clasificacion").text('DOLOR MODERADO').css({color: "purple "})
			else if ( total >= 6 && total <= 8) $("#clasificacion").text('DOLOR FUERTE').css({color: "red "})
			else if ( total >= 9) $("#clasificacion").text('DOLOR SEVERO').css({color: "red"})
		<%} else if(fg.trim().equalsIgnoreCase("CA")){%>
			if (total < 1 ) $("#clasificacion").text('NO DOLOR').css({color: "green"})
			else if ( total >=1 && total <= 3) $("#clasificacion").text('DOLOR LEVE A MODERADO').css({color: "orange"})
			else if ( total >= 4 && total <= 6) $("#clasificacion").text('DOLOR MODERADO A GRAVE').css({color: "purple "})
			else if ( total > 6) $("#clasificacion").text('DOLOR MUY FUERTE').css({color: "red"})
		<%}else if(fg.trim().equalsIgnoreCase("FOUR")){%>
			if (total <= 8) $("#clasificacion").text('NOTIFICAR AL MÉDICO').css({color: "red"})
			else $("#clasificacion").text('').css({color: "inherit"})
		<%}else if(fg.trim().equalsIgnoreCase("RAM")){%>
			if (total >= 4) $("#clasificacion").text('NOTIFICAR AL MÉDICO').css({color: "red"})
			else $("#clasificacion").text('').css({color: "inherit"})
		<%}%>
}

			function clickInterv(e){
				<%if(request.getParameter("showIntervention")!=null && request.getParameter("showIntervention").equalsIgnoreCase("Y")){%>
						var total = '<%=eTotal%>';
						showIntervention = true;
				<%}else{%>
						var showIntervention = false;
						var total = $("#total2").val() || 0;
				<%}%>
			var url = '../expediente3.0/exp_intervencion_list.jsp?fg=<%=fg%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id_escala=<%=id%>&total='+total;
				<%if(modeSec.equalsIgnoreCase("view")){%>
						if(showIntervention){
							<%if(fp.trim().equals("SV")){%>top.showInterv(url, {screwTheUser:true});<%}else{%>parent.showInterv(url, {screwTheUser:true});<%}%>
						}else{
								url += '&mode=<%=modeSec%>';
							 <%if(fp.trim().equals("SV")){%>top.showInterv(url, {screwTheUser:false});<%}else{%>parent.showInterv(url, {screwTheUser:false});<%}%>
						}
				<%} else {%>
						<%if(fp.trim().equals("SV")){%>top.showInterv(url, {screwTheUser:true});<%}else{%>parent.showInterv(url, {screwTheUser:true});<%}%>
				<%}%>
				return;
		 }
$(function(){
	 /*$("#__intervencion").click(function(e){
			 var total = $("#total2").val() || 0;
			 var url = '../expediente3.0/exp_intervencion_list.jsp?fg=<%=fg%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=<%=mode%>&id_escala=<%=id%>&total='+total;

			 //var printWindow = window.open(url, '', 'height=400,width=800');
			 //printWindow.document.close();
			 //printWindow.print();

			 parent.showInterv(url, true);
	 });*/


	 //
	 $("input[name*='escala']").click(function(c){
		 var escala = $(this).data('escala') || '0';
		 escala = parseInt(escala, 10);
		 var escalaValidator = <%=fg.trim().equalsIgnoreCase("MM5")?"2":"0"%>;
		 if (escala > escalaValidator) {
			 if($("#tipo_dolor").find("input[type='checkbox']").length) $("#showing_tipo_dolor").val("Y");
			 $("#tipo_dolor").show(0);
		 } else {
			 $("#showing_tipo_dolor").val("N");
			 $("#tipo_dolor").hide(0);
			 $("input[name*='aplicarD'], input[name*='aplicarMe']").prop("checked", false);
			 document.getElementById("localizacion").value = "";
		 }
	 });

	 // reloading alerts
	if (typeof parent.reloadAlerts === 'function') parent.reloadAlerts();
	else if (typeof parent.parent.reloadAlerts === 'function') parent.parent.reloadAlerts();

	doAction();
});

function canSubmit () {
		var proceed = true;
		if ( $("#showing_tipo_dolor").val() === "Y" ) {
			 if ( !$("input:checked[type='checkbox'][name*='aplicarD']").length ) {
				 proceed = false;
				 CBMSG.error("Por favor seleccionar al menos un tipo de dolor!");
			 } else if ( !$("input:checked[type='checkbox'][name*='aplicarMe']").length ) {
				 proceed = false;
				 CBMSG.error("Por favor indicar en que momento se presenta el dolor!");
			 } else if ( !$.trim($("#localizacion").val()) ) {
				 proceed = false;
				 CBMSG.error("Por favor ingresar información en Área o Localización!");
			 }
		} else {
			proceed = true;
		}
		return proceed;
}

function printXHora() {
	var fecha = $("#rpt_fecha").val();
	var rpt = "";
	<%if(fg.trim().equalsIgnoreCase("AN") || fg.trim().equalsIgnoreCase("MM5") || fg.trim().equalsIgnoreCase("CA")){%>
		rpt = "rpt_escalas_del_dolor.rptdesign";
	<%} else if (fg.trim().equalsIgnoreCase("MAC") || fg.trim().equalsIgnoreCase("DO") || fg.trim().equalsIgnoreCase("FOUR") || fg.trim().equalsIgnoreCase("RAM")){%>
		rpt = "rpt_escalas_caidas.rptdesign";
	<%}%>
	if(fecha && rpt)abrir_ventana1('../cellbyteWV/report_container.jsp?reportName=expediente/'+rpt+'&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tipo=<%=fg%>&tipo_desc=<%=desc%>&pCtrlHeader=false&pFecha='+fecha);
}

function verHistorial() {
	$("#hist_container").toggle();
}
</script>
</head>

<body class="body-form">
<div class="row">

<div class="table-responsive" data-pattern="priority-columns">
<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%fb.appendJsValidation("if(!canSubmit()) { error++; }");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("opcion","0")%>
<%=fb.hidden("valIni","0")%>
<%=fb.hidden("fg",""+fg)%>
<%=fb.hidden("id",""+id)%>
<%=fb.hidden("sizeD",""+al3.size())%>
<%=fb.hidden("sizeIM",""+al4.size())%>
<%=fb.hidden("sizeNF",""+al5.size())%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("showing_tipo_dolor", "")%>
<%=fb.hidden("fp",""+fp)%>
<%if(!fp.trim().equalsIgnoreCase("SV")){%>
<div class="headerform">

<table cellspacing="0" class="table pull-right table-striped table-custom-2">

<tr>
<td class="controls form-inline">
 <%if(fg.trim().equalsIgnoreCase("MO")&&!fp.trim().equalsIgnoreCase("SV")){%>
	<%=fb.button("btnHelp","Ayuda",false,false,"btn btn-inverse btn-sm|fa fa-exclamation-circle fa-printico",null,"onClick=\"javascript:ayuda()\"")%>
 <%}%>
 <%if(!fp.trim().equalsIgnoreCase("SV")){%>
	<%=fb.button("btnHelp","Consultar",false,false,"btn btn-inverse btn-sm|fa fa-search fa-printico",null,"onClick=\"javascript:consultar()\"")%>
<%if(!mode.trim().equalsIgnoreCase("view")){%>
	<%=fb.button("btnAdd","Agregar",true,false,"btn btn-inverse btn-sm|fa fa-plus fa-printico",null,"onClick=\"javascript:add()\"")%>
 <%}%>
 <%if(!id.trim().equals("0")){%>
	<%=fb.button("btnPrint","Imprimir",false,false,"btn btn-inverse btn-sm|fa fa-print fa-printico",null,"onClick=\"javascript:imprimir()\"")%>
 <%}%>

<%if(al2.size() > 0){%>
	<%=fb.button("btnAdd","Imprimir Todas",false,false,"btn btn-inverse btn-sm|fa fa-print fa-printico",null,"onClick=\"javascript:imprimir(1)\"")%>
<%}%>

<%if(fg.trim().equalsIgnoreCase("AN") || fg.trim().equalsIgnoreCase("MM5") || fg.trim().equalsIgnoreCase("CA") || fg.trim().equalsIgnoreCase("MAC") || fg.trim().equalsIgnoreCase("DO") || fg.trim().equalsIgnoreCase("FOUR") || fg.trim().equalsIgnoreCase("RAM")){%>
<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
<jsp:param name="noOfDateTBox" value="1" />
<jsp:param name="clearOption" value="true" />
<jsp:param name="nameOfTBox1" value="rpt_fecha" />
<jsp:param name="valueOfTBox1" value="<%=escala.getFecha()%>" />
</jsp:include>
	<%=fb.button("btnPrintHourly","Por Hora",false,false,"btn btn-inverse btn-sm|fa fa-print fa-printico",null,"onClick=\"javascript:printXHora()\"")%>
 <%}%>

 <%if(al2.size() > 0){%>
	<%=fb.button("btnHistory","Historial",false,false,"btn btn-inverse btn-sm|fa fa-eye fa-printico",null,"onClick=\"javascript:verHistorial()\"")%>
	<%}%>
	<%}%>

</td>
</tr>
</table>

<div class="table-wrapper" id="hist_container" style="display:none">
<table cellspacing="0" class="table table-small-font table-bordered table-striped">
<thead>
<tr><th colspan="7" class="bg-headtabla"><cellbytelabel>Listado de Evaluaciones [ Escala ]</cellbytelabel></th></tr>
<tr class="bg-headtabla2">
		<th><cellbytelabel>Fecha</cellbytelabel></th>
		<th><cellbytelabel>Hora</cellbytelabel></th>
		<th><cellbytelabel>Total</cellbytelabel></th>
		<th><cellbytelabel>Creado Por</cellbytelabel></th>
		<th><cellbytelabel>Modif. por</cellbytelabel></th>
		<th><cellbytelabel>Fecha/Hora Mod</cellbytelabel>.</th>
		<th><cellbytelabel>Fecha Recup</cellbytelabel>.</th>
</tr>
<tbody>
<%
for (int i=1; i<=al2.size(); i++)
{
	cdo = (CommonDataObject) al2.get(i-1);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
	%>

		<%=fb.hidden("code"+i,cdo.getColValue("id"))%>
		<%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
		<%=fb.hidden("hora"+i,cdo.getColValue("hora"))%>
		<%=fb.hidden("temp_total"+i,cdo.getColValue("total"))%>
		<%=fb.hidden("total_tmp"+i,cdo.getColValue("total"))%>

		<tr class="pointer" onClick="javascript:verEscala(<%=i%>,'view')">
						<td><%=cdo.getColValue("fecha")%></td>
						<td><%=cdo.getColValue("hora")%></td>
						<td align="center"><%=cdo.getColValue("total")%></td>
						<td><%=cdo.getColValue("usuario")%></td>
						<td><%=cdo.getColValue("usuarioMod")%></td>
						<td><%=cdo.getColValue("fechaMod")%>/<%=cdo.getColValue("horaMod")%></td>
						<td><%=cdo.getColValue("fecha_recup")%></td>
		</tr>
<%
}
%>
</tbody>
</table>
</div>
 </div>
<%}%>
<table cellspacing="0" class="table table-small-font table-bordered table-striped">
		<tr>
				<td><cellbytelabel>Fecha</cellbytelabel></td>
				<td class="controls form-inline">
						<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox1" value="fecha" />
						<jsp:param name="valueOfTBox1" value="<%=escala.getFecha()%>" />
						<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
						</jsp:include></td>
				<td><cellbytelabel>Hora</cellbytelabel></td>
				<td class="controls form-inline">
						<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1"/>
						<jsp:param name="format" value="hh12:mi:ss am"/>
						<jsp:param name="nameOfTBox1" value="hora" />
						<jsp:param name="valueOfTBox1" value="<%=escala.getHora()%>" />
						<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
						</jsp:include>
				 </td>
		</tr>
</table>

<table cellspacing="0" class="table table-small-font table-bordered table-striped">

<%if(!modeSec.trim().equalsIgnoreCase("add") && (fg.trim().equalsIgnoreCase("BR") || fg.trim().equalsIgnoreCase("MM5") || fg.trim().equalsIgnoreCase("DO") || fg.trim().equalsIgnoreCase("CA") || fg.trim().equalsIgnoreCase("AN")|| fg.trim().equalsIgnoreCase("MAC")|| fg.trim().equalsIgnoreCase("TVP") )){%>
<tr>
		<td align="right" colspan="3">
			<%=fb.button("btnInter","Intervenciones",false,false,"btn btn-inverse",null,"onClick=\"javascript:clickInterv(event)\"",null,"data-fg=\""+fg+"\"","__intervencion")%>
		</td>
</tr>
<%}
if(request.getParameter("showIntervention")!=null && request.getParameter("showIntervention").equalsIgnoreCase("Y")){
%>
<script>
$("#__intervencion").click();
 </script>
<%}%>
<tr class="bg-headtabla2" align="center">
		<td><cellbytelabel><%if(!fg.trim().equalsIgnoreCase("MAC")){%>Descripci&oacute;n<%}else{%>Variables<%}%></cellbytelabel></td>
		<td><cellbytelabel><%if(!fg.trim().equalsIgnoreCase("MAC")){%>Escala<%}else{%>Puntaje<%}%></cellbytelabel></td>
		<td><cellbytelabel>Observaci&oacute;n</cellbytelabel></td>
</tr>
<%
		int lc=0 ,De=0 ;
		String codE = "", observ = "";
		String codAnt = "";
		String detalleCod = "";
		boolean codDetSig = false;
		for (int i = 0; i <al.size(); i++){
				key = al.get(i).toString();
				cdo = (CommonDataObject) al.get(i);
				codE = cdo.getColValue("codigo");

				String color = "TextRow02";
				if (i % 2 == 0) color = "TextRow01";

				if(cdo.getColValue("cod_escala").equalsIgnoreCase("0")){
			De=0;
			lc++;
			detalleCod = cdo.getColValue("detalle");
			observ = cdo.getColValue("observacion");

			if(cdo.getColValue("detalle").equalsIgnoreCase("0") && !viewMode ){
				codDetSig = true;
			}%>
			<%=fb.hidden("cod_escala"+lc,cdo.getColValue("codigo"))%>
			<%=fb.hidden("codDetalle"+lc,"0")%>
			<%=fb.hidden("valor"+lc,"0")%>

			<tr>
				<td align="center" width="34%"><%=cdo.getColValue("descripcion")%></td>
					<td width="33%">
						<table border="0" cellpadding="0" cellspacing="0" class="table table-small-font table-bordered table-striped">
						<%
						}
						else if(!cdo.getColValue("cod_escala").equalsIgnoreCase("0")){
						%>
								<%=fb.hidden("valorCH"+lc+De,cdo.getColValue("escala"))%>
								<%=fb.hidden("codDetalle"+lc+De,cdo.getColValue("cod_escala"))%>
								<tr>
										<td width="5%" valign="middle" >
												<%=fb.radio("escala"+lc, cdo.getColValue("cod_escala"),(detalleCod.equalsIgnoreCase(cdo.getColValue("cod_escala"))|| codDetSig ),viewMode, false , "", "", "onClick=\"javascript:setEscalaValor('"+lc+"','"+cdo.getColValue("cod_escala")+"','"+cdo.getColValue("escala")+"')  \"",null," data-escala="+cdo.getColValue("escala"))%>
										</td>
										<td width="75%" valign="middle"><%=cdo.getColValue("descripcion")%></td>
										 <%if(fg.trim().equalsIgnoreCase("WB")){%>
												<td width="10%" valign="middle"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" src="../images/dolor<%=cdo.getColValue("cod_escala")%>.gif"> </td>
										 <%}%>
										 <td width="10%" align="right" valign="middle"><%=cdo.getColValue("escala")%></td>
								</tr>
								<%
										codDetSig=false;
					if(i<al.size()-1){
												cdo = (CommonDataObject) al.get(i+1);
						codAnt = cdo.getColValue("codigo");
					}else{
								%>
						</table>
					</td>
					<td width="33%"><%=fb.textarea("observacion"+lc,observ,false,false,viewMode,50,0,2000,"form-control input-sm","width:100%",null)%></td>
			</tr>
						<%
						detalleCod="";
			}
						if(!codAnt.equalsIgnoreCase(codE)){
			%>
						</table>
						</td>
						<td><%=fb.textarea("observacion"+lc,observ,false,false,viewMode,50,0,2000,"form-control input-sm","width:100%",null)%></td>
			</tr>
			<%	detalleCod="";}
				De++;
				}//else%>
				<%}%>
			<tr class="TextRow02">
				<td>&nbsp;</td>
				<td align="right" class="controls form-inline"><cellbytelabel>Total</cellbytelabel>:
				<%=fb.intBox("total2",tmpTot,false,false,true,5,0,"form-control input-sm",null,null)%></td>
				<td><b><label id="clasificacion" style="color:green">&nbsp;</label></b></td>
				</tr>
<%=fb.hidden("size",""+lc)%>
</table>

<table id="tipo_dolor"<%=!modeSec.trim().equalsIgnoreCase("add")?"":"style='display:none'"%>cellspacing="0" class="table table-small-font table-bordered table-striped">
<%if(fg.trim().equalsIgnoreCase("AN") || fg.trim().equalsIgnoreCase("MM5") || fg.trim().equalsIgnoreCase("CA")){%>
		<tr class="bg-headtabla">
				<td colspan="3"><cellbytelabel>Descripci&oacute;n de los C&oacute;digos</cellbytelabel> </td>
		</tr>
	<tr>
				<td>
						<table border="0" cellpadding="0" cellspacing="0" class="table table-small-font table-bordered table-striped">
								<tr class="TextHeader" align="center">
										<td><strong>Tipo de Dolor</strong></td>
								</tr>
								<%for (int i=1; i<=al3.size(); i++){
										cdo = (CommonDataObject) al3.get(i-1);
										%>

												<%=fb.hidden("idD"+i,cdo.getColValue("codigo"))%>

												<tr>
														<td>
														<label class="pointer">
														<%=fb.checkbox("aplicarD"+i,"S",(CmnMgr.vectorContains(v1,cdo.getColValue("codigo"))),viewMode,null,null,"")%>
															<%=cdo.getColValue("descripcion")%></label>
														</td>
												</tr>
								<%}%>
			</table>
		</td>
		<td>
			<table border="0" cellpadding="0" cellspacing="0" class="table table-small-font table-bordered table-striped">
								<tr>
										<td><strong>Dolor Al</strong></td>
								</tr>
								<%for (int i=1; i<=al4.size(); i++){
										cdo = (CommonDataObject) al4.get(i-1);
										%>

												<%=fb.hidden("idMe"+i,cdo.getColValue("codigo"))%>

												<tr class="tbg-error">
																<td><label class="pointer">
																<%=fb.checkbox("aplicarMe"+i,"S",(CmnMgr.vectorContains(v2,cdo.getColValue("codigo"))),viewMode,null,null,"")%>
																<%=cdo.getColValue("descripcion")%></label></td>
												</tr>
								<%}%>

			</table>
		</td>
				<td>
						<table border="0" cellpadding="0" cellspacing="0" class="table table-small-font table-bordered table-striped">
								<tr>
										<td width="90%"><strong>&Aacute;rea o Localizaci&oacute;n <strong></td>
								</tr>
										<%//for (int i=1; i<=al5.size(); i++){
												//cdo = (CommonDataObject) al5.get(i-1);
												// String color = "TextRow02";
												 //if (i % 2 == 0) color = "TextRow01";
												%>
														<%//=fb.hidden("idNf"+i,cdo.getColValue("codigo"))%>
														<!--<tr class="<%//=color%>" valign="top">
																		<td><label class="pointer"><%//=fb.checkbox("aplicarNf"+i,"S",(CmnMgr.vectorContains(v2,cdo.getColValue("codigo"))),viewMode,null,null,"")%>
																		<%//=cdo.getColValue("descripcion")%></label></td>
														</tr>-->
												<%//}%>

												<tr valign="top">
												<td>
												<%=fb.textarea("localizacion",escala.getLocalizacion(),false,false,viewMode,0,0,2000,"form-control input-sm","width:100%",null)%>
												</td>
												</tr>

					</table>
				</td>
</tr>

<%}else{%>
		<%if(!fg.trim().equalsIgnoreCase("MAC")&&!fg.trim().equalsIgnoreCase("MM5")&&!fg.trim().equalsIgnoreCase("FOUR")&&!fg.trim().equalsIgnoreCase("TVP")&&!fg.trim().equalsIgnoreCase("RAM")){%>
		<tr>
				<td align="right"><cellbytelabel>Intervenci&oacute;n</cellbytelabel></td>
				<td colspan="2"><%=fb.textarea("intervencion",escala.getIntervencion(),false,false,viewMode,40,0,2000,"form-control input-sm","width:100%",null)%></td>
		</tr>
		<%}%>
<%}%>

</table>



<div class="footerform"><table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
<tr>
			<td>
				<%=fb.hidden("saveOption","O")%>
				<%=fb.submit("save","Guardar",true,viewMode,"btn btn-inverse btn-sm",null,null)%>
				<%//=fb.button("cancel","Cancelar",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>
		</table> </div>

			<%=fb.formEnd(true)%>
			<script type="text/javascript">sumaEscala("<%=eTotal%>");</script>


	</div>
</div>
</body>
</html>
<%
}//fin GET
else
{
	String saveOption = request.getParameter("saveOption")==null?"":request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	int size = 0;
	int tpuntos=0;
	String dolor ="",intervencion="",totalEscala="";

	Escalas eco = new Escalas();
	eco.setAdmision(request.getParameter("noAdmision"));
	eco.setPacId(request.getParameter("pacId"));
	eco.setFecha(request.getParameter("fecha"));
	eco.setHora(request.getParameter("hora"));
	eco.setTipo(request.getParameter("fg"));
	eco.setId(request.getParameter("id"));
	eco.setTotal(request.getParameter("total2"));
	totalEscala = request.getParameter("total2");
	eco.setLocalizacion(request.getParameter("localizacion"));
	eco.setUsuario((String) session.getAttribute("_userName"));
	if (request.getParameter("sizeD") != null) size = Integer.parseInt(request.getParameter("sizeD"));
	for (int i=1; i<=size; i++)
	{
		if (request.getParameter("aplicarD"+i) != null && request.getParameter("aplicarD"+i).equalsIgnoreCase("S"))
		{
			if(!dolor.trim().equalsIgnoreCase(""))
			dolor += "|"+request.getParameter("idD"+i);
			else dolor += request.getParameter("idD"+i);
		}
	}
	if (request.getParameter("sizeIM") != null) size = Integer.parseInt(request.getParameter("sizeIM"));
	for (int i=1; i<=size; i++)
	{
		if (request.getParameter("aplicarMe"+i) != null && request.getParameter("aplicarMe"+i).equalsIgnoreCase("S"))
		{
			if(!intervencion.trim().equalsIgnoreCase(""))
			intervencion += "|"+request.getParameter("idMe"+i);
			else intervencion += request.getParameter("idMe"+i);
		}
	}
	if (request.getParameter("sizeNF") != null) size = Integer.parseInt(request.getParameter("sizeNF"));
	for (int i=1; i<=size; i++)
	{
		if (request.getParameter("aplicarNf"+i) != null && request.getParameter("aplicarNf"+i).equalsIgnoreCase("S"))
		{
			if(!intervencion.trim().equalsIgnoreCase(""))
			intervencion +="|"+request.getParameter("idNf"+i);
			else intervencion +=request.getParameter("idNf"+i);
		}
	}



if(!fg.trim().equalsIgnoreCase("MO") && !fg.trim().equalsIgnoreCase("DO"))
eco.setIntervencion(""+intervencion);
else eco.setIntervencion(request.getParameter("intervencion"));

eco.setDolor(""+dolor);


if (request.getParameter("size") != null) size = Integer.parseInt(request.getParameter("size"));

for (int i=1; i<=size; i++)
{
			if(request.getParameter("escala"+i) != null){
			DetalleEscala dre = new DetalleEscala();

			dre.setTipo(request.getParameter("fg"+i));//codigo
			dre.setCodEscala(request.getParameter("cod_escala"+i));//codigo

			/*if(request.getParameter("valIni").equalsIgnoreCase("1"))
			{
					dre.setDetalle(request.getParameter("codDetalleL"+i));//codDetalle
					dre.setValor(request.getParameter("valorL"+i));//
					tpuntos += Integer.parseInt(request.getParameter("valorL"+i));
			}
			else*/
			if(request.getParameter("escala"+i) != null)
			{
					dre.setDetalle(request.getParameter("codDetalle"+i));//codDetalle
					dre.setValor(request.getParameter("valor"+i));//
					//tpuntos = Integer.parseInt(request.getParameter("total2"));
			}


			dre.setAplicar("S");//
			dre.setObservacion(request.getParameter("observacion"+i));	//obsservacion

			eco.addDetalleEscala(dre);
			}
}
					//eco.setTotal(""+tpuntos);
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());

					if(modeSec.trim().equalsIgnoreCase("add"))
					{
							ECMgr.add(eco);
							id=ECMgr.getPkColValue("id");
					}
					else
					{
							ECMgr.update(eco);
							id=request.getParameter("id");
					}
			ConMgr.clearAppCtx(null);


%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (ECMgr.getErrCode().equalsIgnoreCase("1"))
{
%>
	alert('<%=ECMgr.getErrMsg()%>');
	<%//if(!fp.trim().equals("SV")){%>
	if(parent.window.setValEscala)parent.window.setValEscala(<%=totalEscala%>);
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=<%=id%>&fg=<%=fg%>&fp=<%=fp%>&desc=<%=desc%>&eTotal=<%=request.getParameter("total2")%><%=!fg.equalsIgnoreCase("RAM")?"&showIntervention=Y":""%>';

	<%//}else {%>//parent.hidePopWin(false);<%//}%>
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente3.0/exp_escalas_dolor.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/exp_escalas_dolor.jsp?")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
<%	} %>
<%
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
} else throw new Exception(ECMgr.getErrMsg());
%>
}
function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=<%=id%>&fg=<%=fg%>&fp=<%=fp%>&desc=<%=desc%>&eTotal=<%=request.getParameter("total2")%>&fecha=<%=fecha%><%=!fg.equalsIgnoreCase("RAM")?"&showIntervention=Y":""%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>