		<!--Bienvenido a CELLBYTE Expediente Electronico V3.0 Build 1.4 BETA-->
		<!--Bootstrap 3, JQuery UI Based, HTML5 y {LESS}-->
		<!--Para mas Informacion leer (info_v3.txt)-->
		<!--Done by. eduardo.b@issi-panama.com-->
		<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iAlergia" scope="session" class="java.util.Hashtable" />
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
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String fg = request.getParameter("fg");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (fg == null) fg = "";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}

		String join = "";

		if (!fg.equalsIgnoreCase("plan_salida")) join = "(+)";

	sql = "select a.descripcion as descripcion, a.codigo as codigoalergia, to_char(b.fecha,'dd/mm/yyyy hh12:mi:ss am') as fecha, b.meses as meses, b.observacion as observacion, b.edad as edad, nvl(b.codigo,0) as cod, b.aplicar as aplicar,decode(b.tipo_alergia,null,'I','U') action,to_char(b.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am')fecha_creacion,b.usuario_creacion, fn_sal_ant_history("+pacId+", "+noAdmision+", "+seccion+",'admision','observacion','tipo_alergia',a.codigo) history, a.es_default ,(select count(*) from tbl_sal_alergia_paciente b, tbl_sal_tipo_alergia a where b.pac_id = "+pacId+" and b.admision = "+noAdmision+" and a.codigo = b.tipo_alergia and a.es_default <> 'S') tot_saved from TBL_SAL_TIPO_ALERGIA a, TBL_SAL_ALERGIA_PACIENTE b where a.codigo=b.tipo_alergia"+join+" and b.pac_id"+join+"="+pacId+" and b.admision"+join+" = "+noAdmision+" ORDER BY a.orden ";
	al = SQLMgr.getDataList(sql);
%>
		<!DOCTYPE html>
		<html lang="en">
		<!--comienza el head-->
		<head>
		<meta charset="utf-8">
		<title>Expediente Cellbyte</title>
		<%@ include file="../common/nocache.jsp"%>
		<%@ include file="../common/header_param_bootstrap.jsp"%>
		<style>
			.msgBoxButtons input[type='button'] {width: auto !important;}
		</style>
		<script>
		var noNewHeight = true;
document.title = 'EXPEDIENTE - Antecedente Alergico - '+document.title;
function doAction(){newHeight();}
function isChecked(k){
		/*eval('document.form0.observacion'+k).readOnly = !eval('document.form0.aplicar'+k).checked;
		eval('document.form0.edad'+k).readOnly = !eval('document.form0.aplicar'+k).checked;
		eval('document.form0.meses'+k).readOnly = !eval('document.form0.aplicar'+k).checked;*/
}
function imprimirExp(){abrir_ventana('../expediente3.0/print_exp_seccion_11.jsp?pacId=<%=pacId%>&seccion=<%=seccion%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&exp=3');}

$(function(){
	$(".history").tooltip({
	content: function () {
		var $i = $(this).data("i");
		var $title = $($(this).prop('title'));
		var $content = $("#historyCont"+$i).val();
		var $cleanContent = $($content).text();
		if (!$cleanContent) $content = "";
		return $content;
	}
	,track: true
	});

	$("input:checkbox[name*='aplicar']").not(".default").click(function(e){
		var _default = $("input:checkbox[data-default='S']");
		if (_default.is(":checked")) {
			 e.preventDefault();
			 return false;
		} else {
				var self = $(this);
				var i = self.data('i');
				ctrlFields(i, self.is(":checked"));
		}
	});

	$(".default").click(function(){
		var self = $(this);
		var i = self.data('i');

		if ((tot = $("input.action-without-default[value='U']").length) > 0) {
			if (!confirm("Estas seguro de querer quitar las alergias?")) return false;
		}

		if (this.checked) {
				$("input:checkbox[name*='aplicar']").not(self).prop("checked", false).each(function(){
						ctrlFields($(this).data('i'), $(this).is(":checked"));
				});
				$(".field").not(self).prop("readOnly", true).val("");
				ctrlFields(i, true)
		} else ctrlFields(i, false)
	});

	// init tooltip
	$('[data-toggle="tooltip"]').tooltip();


	// reloading alerts
	if (typeof parent.reloadAlerts === 'function') parent.reloadAlerts();
	else if (typeof parent.parent.reloadAlerts === 'function') parent.parent.reloadAlerts();
});

function ctrlFields(i, isChecked) {
		var action = $("#action_tmp"+i).val();
		if (isChecked) {
				$("#observacion"+i).prop("readOnly", false);
				$("#edad"+i).prop("readOnly", false);
				$("#meses"+i).prop("readOnly", false);
				$("#action"+i).val(action);
		} else {
				$("#observacion"+i).prop("readOnly", true).val("");
				$("#edad"+i).prop("readOnly", true).val("");
				$("#meses"+i).prop("readOnly", true).val("");
				if (action == 'U') $("#action"+i).val("D");
		}
}

function confirmRemoveAlergia() {
		var alergias = [];
		$("input[name^='action_tmp'][value='U']").not(".action-without-default").each(function(){
				var self = $(this);
				var i = self.data('i');
		});
		$("#__alergias__").val(alergias.join());
}

function canProceed() {
	if ($("#force_submit").val() === 'Y') return true;
	
	var _default = $("input:checkbox[data-default='S']");
	if (_default.is(":checked")) {

		var history = getDBData('<%=request.getContextPath()%>','count(*)','tbl_sal_alergia_paciente al, tbl_sal_tipo_alergia b',"al.pac_id = <%=pacId%> and al.admision <> <%=noAdmision%> and al.aplicar = 'S' and al.tipo_alergia = b.codigo and b.es_default <> 'S' and exists(select null from tbl_sec_alert where  pac_id = <%=pacId%> and name = 'TBL_SAL_ALERGIA_PACIENTE' and alert_type = 1 and status = 'A' and ref_code1 not in (select codigo from tbl_sal_tipo_alergia where nvl(es_default,'N') = 'S'))",'');
		
		if (parseInt(history)) {
			parent.CBMSG.confirm("<strong style='color: red'>Paciente ya tiene documentado historia de alergias distinto.<br><br>Esta seguro de Negar Alergias en esta atención y eliminar las Alertas que mantiene?<strong>", {btnTxt:"ESTOY SEGURO,VERIFICAR HISTORIAL", opacity: .5, cb: function(r){
			  if (r == 'ESTOY SEGURO') {
				  $("#force_submit").val("Y");
				  $("#form0").submit();
				  return true;
			  }
			  else {
				  //document.getElementById("btnHistory").click();
				  return false;
			  }
			}});
		} else return true;
		
		/*if (parseInt(history)) {
			if (confirm("Paciente ya tiene documentado historia de alergias distinto.\n\nEsta seguro de Negar Alergias en esta atención y eliminar las Alertas que mantiene?")) return true;
			else return false;
		} else return true;*/

	} else return true;
}
</script>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script>
		</head>
		<!--termina el head-->

		<!--comienza el cuerpo del sitio-->
		<body class="body-form">

				<!-----------------------------------------------------------------/INICIO Fila de Peneles/--------------->
		<!--INICIO de una fila de elementos-->
		<div class="row">
		<!--INICIO de una fila de elementos-->

		<div class="table-responsive" data-pattern="priority-columns">
		<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("size",""+al.size())%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%fb.appendJsValidation("if(!canProceed()) error++;");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("__alergias__", "")%>
<%=fb.hidden("force_submit", "")%>

		<!--tabla de boton imprimit-->
				<div class="headerform">
		<table cellspacing="0" class="table pull-right table-striped table-custom-1" style="text-align: right !important;">
		<tr>
				<td>
						<%
								CommonDataObject cdoH = SQLMgr.getData("select nvl(join ( cursor( select '[ADM: '||bb.admision||'] '||aa.descripcion from tbl_sal_tipo_alergia aa, tbl_sal_alergia_paciente bb where aa.codigo = bb.tipo_alergia and (nvl(bb.admision,"+noAdmision+") < "+noAdmision+" or bb.admision is null) and bb.pac_id = "+pacId+" order by bb.admision)  ,'<br>'),' ') alergias_history from dual");
								if (cdoH==null) cdoH = new CommonDataObject();
								if(!cdoH.getColValue("alergias_history"," ").trim().equals("")){
						%>
			<%=fb.button("btnHistory","Historial",false,false,"btn btn-inverse btn-sm|fa fa-eye fa-printico",null,"onClick=\"javascript:void(0)\"",cdoH.getColValue("alergias_history"," ")," data-toggle=\"tooltip\" data-placement=\"left\" data-html=\"true\"")%>
						<%}%>
			<%=fb.button("btnPrint","Imprimir",false,false,"btn btn-inverse btn-sm|fa fa-print fa-printico",null,"onClick=\"javascript:imprimirExp()\"")%>
				</td>
		</tr>
		</table>
				</div>
		<!--fin tabla de boton imprimit-->
		<table cellspacing="0" class="table table-small-font table-bordered table-striped">
		<thead>
		<tr class="bg-headtabla">
				<td>Tipo de Alergia</td>
				<td align="center">Si</td>
				<td>Edad</td>
				<td>Meses</td>
				<td>Observación</td>
		</tr>
		</thead>

		<tbody>

		<%
for (int i=0; i<al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

	String history = cdo.getColValue("history").equals("")?"":"Historial";
%>
		<%=fb.hidden("cod_alergia"+i,""+cdo.getColValue("codigoalergia"))%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("cod"))%>
		<%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
		<%=fb.hidden("action"+i,cdo.getColValue("action"))%>
		<%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
		<%=fb.hidden("fecha_creacion"+i,cdo.getColValue("fecha_creacion"))%>
		<%=fb.hidden("historyCont"+i,"<label class='historyCont' style='font-size:11px'>"+(cdo.getColValue("history")==null?"":cdo.getColValue("history"))+"</label>")%>
		<%=fb.hidden("action_tmp"+i,cdo.getColValue("action")," class=\""+(cdo.getColValue("es_default").equalsIgnoreCase("S")?"n":"action-without-default")+"\"", null)%>
		<tr>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td align="center"><%=fb.checkbox("aplicar"+i,"S",cdo.getColValue("aplicar").equalsIgnoreCase("S"),viewMode,cdo.getColValue("es_default"," ").equalsIgnoreCase("S")?"default":"",null,"onClick=\"javascript:isChecked("+i+")\"",null," data-default='"+cdo.getColValue("es_default")+"' data-i="+i)%></td>
			<td><%=fb.intBox("edad"+i,cdo.getColValue("edad"),false,false,viewMode||(!cdo.getColValue("aplicar").equalsIgnoreCase("S")),4,3,"form-control input-sm field",null,null)%></td>
			<td><%=fb.intBox("meses"+i,cdo.getColValue("meses"),false,false,viewMode||(!cdo.getColValue("aplicar").equalsIgnoreCase("S")),4,3,"form-control input-sm field",null,null)%></td>
			<td align="left"><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,viewMode||(!cdo.getColValue("aplicar").equalsIgnoreCase("S")),50,1,2000,"form-control input-sm field","width='100%'",null)%></td>
			<!--<td align="center">
				<span class="history" title="" data-i="<%=i%>"><span class="Link00 pointer"><%=history%></span></span>
			</td>-->
		</tr>

				<%}%>

		</tbody>
		</table>

		 <%if(!fg.equalsIgnoreCase("plan_salida")){%>
		 <div class="footerform">
		 <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">

		<tr>
			<td>
				<%=fb.hidden("saveOption","O")%>
				<%=fb.submit("save","Guardar",true,viewMode,"btn btn-inverse btn-sm",null,null)%>
				<%//=fb.button("cancel","Cancelar",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>

		</table>
		</div>
		<%}%>

		<%=fb.formEnd(true)%>
		</div>

		<!-- FIN contenido del sitio aqui-->
		</div>
		<!-- FIN contenido del sitio aqui-->


		<!-- FIN Cuerpo del sitio -->
		</body>
		<!-- FIN Cuerpo del sitio -->


		</html>
		<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("size"));
	al.clear();

	for (int i=0; i<size; i++)
	{
		cdo = new CommonDataObject();
		cdo.setTableName("TBL_SAL_ALERGIA_PACIENTE");

		if (request.getParameter("aplicar"+i)!= null && request.getParameter("aplicar"+i).equalsIgnoreCase("S"))
		{
			if(request.getParameter("action"+i) != null && request.getParameter("action"+i).trim().equals("U")){
								cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and codigo ="+request.getParameter("codigo"+i)+" and nvl(admision,"+request.getParameter("noAdmision")+") = "+request.getParameter("noAdmision"));
								cdo.setAction("U");
								cdo.addColValue("fecha_modificacion",cDateTime);
								cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
						} else {
								cdo.setAction("I");
								cdo.addColValue("COD_PACIENTE",request.getParameter("codPac"));
								cdo.addColValue("FEC_NACIMIENTO", request.getParameter("dob"));
								cdo.addColValue("PAC_ID",request.getParameter("pacId"));
								cdo.addColValue("admision",request.getParameter("noAdmision"));
								cdo.addColValue("fecha_creacion",cDateTime);
								cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
								if (request.getParameter("codigo"+i).equals("0")||request.getParameter("codigo"+i).trim().equals("")) {
										cdo.setAutoIncCol("codigo");
										cdo.setAutoIncWhereClause("pac_id = "+request.getParameter("pacId"));
								}
						}

			cdo.addColValue("EDAD",request.getParameter("edad"+i));
			cdo.addColValue("OBSERVACION",request.getParameter("observacion"+i));
			if(request.getParameter("fecha"+i).trim().equals(""))cdo.addColValue("FECHA","sysdate");
			else cdo.addColValue("FECHA",request.getParameter("fecha"+i));
			cdo.addColValue("TIPO_ALERGIA",request.getParameter("cod_alergia"+i));
			cdo.addColValue("MESES",request.getParameter("meses"+i));
			cdo.addColValue("APLICAR","S");
			al.add(cdo);
		}
		else {
			if (request.getParameter("action"+i).trim().equalsIgnoreCase("D")){
								cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and codigo ="+request.getParameter("codigo"+i)+" and nvl(admision,"+request.getParameter("noAdmision")+") = "+request.getParameter("noAdmision"));
								cdo.setAction("D");
								al.add(cdo);
						}
		}
	}//for

	if (al.size() == 0)
	{
		cdo = new CommonDataObject();

		cdo.setTableName("TBL_SAL_ALERGIA_PACIENTE");
		cdo.setWhereClause("pac_id="+request.getParameter("pacId"));
		cdo.setAction("I");
		al.add(cdo);
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
				SQLMgr.saveList(al,true);
	ConMgr.clearAppCtx(null);
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
